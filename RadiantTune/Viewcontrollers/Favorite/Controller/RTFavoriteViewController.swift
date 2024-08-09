//
//  RTFavoriteViewController.swift
//  RadiantTune
//
//  Created by Aaribna Gurung on 5/29/24.
//

import UIKit
import Lottie

class RTFavoriteViewController: RTBaseViewController, RTPlayerWidgetViewDelegate {
    
    
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var trashUIButton: UIButton!
    @IBOutlet weak var playerWidget: RTPlayerWidgetView!
    
    var currentStation: Station?
    var emptyLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var favoriteStations: [Station] = []
    var previouslySelectedIndexPath: IndexPath?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the default Red navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        favoriteTableView.reloadData()
        if let station = RTDatabaseManager.shared.activeStation {
            currentStation = station
            playerWidget.station = station
            playerWidget.refreshState(station: station)
            playerWidget.isHidden = false
        } else {
            playerWidget.isHidden = true
        }
      
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayerWidgetConstraints(in: self, playerWidget: playerWidget)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavorites), name: NSNotification.Name(Constants.FavoritesUpdated), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesCleared), name: NSNotification.Name("FavoritesCleared"), object: nil)
        addLoadingIndicator()
        initialSetup()
        addEmptyLabel()
        playerWidget.delegate = self
    }
    
    @objc func handleFavoritesCleared() {
        self.favoriteStations.removeAll()
        self.favoriteTableView.reloadData()
        self.updateEmptyStateUI()
    }
    
    
    @objc func refreshFavorites() {
        initialSetup()
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    


    private func addLoadingIndicator() {
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func initialSetup() {
        
        trashUIButton.setTitle("", for: .normal)
        
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).sync {
            let favorites = RTDatabaseManager.shared.fetchFavorites()
            DispatchQueue.main.async {
                self.favoriteStations = favorites
                self.favoriteTableView.reloadData()
                self.updateEmptyStateUI()
                self.activityIndicator.stopAnimating()
            }
        }
        
        trashUIButton.addTarget(self, action: #selector(trashButtonTapped(_:)), for: .touchUpInside)
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self
        
    }
    
    
    func addEmptyLabel() {
        
        emptyLabel = UILabel()
        emptyLabel.text = "Your favorites list is currently empty."
        emptyLabel.textColor = UIColor.secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        emptyLabel.isHidden = true
    }
    
    @IBAction func trashButtonTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete All Favourites", style: .destructive) { action in
            self.deleteAllFavorites()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(actionSheet, animated: true)
    }
    
    func deleteAllFavorites() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            RTDatabaseManager.shared.deleteAllFavorites()
            DispatchQueue.main.async {
                // Remove all items from the data source
                self.favoriteStations.removeAll()
                // Update the table view
                self.favoriteTableView.reloadData()
                self.updateEmptyStateUI()
                self.playerWidget.saveButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
        
        
        
    }
    
    func updateEmptyStateUI() {
        
        trashUIButton.isEnabled = !favoriteStations.isEmpty  // Disable the button if the array is empty
        emptyLabel.isHidden = !favoriteStations.isEmpty      // show the emty label
        
    }
    
}

extension RTFavoriteViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.favoriteTableViewCell, for: indexPath) as! RTFavoriteStationCell
        
        let station = favoriteStations[indexPath.row]
        
        if station.favicon.contains("http") {
            cell.logoView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
        } else if !station.favicon.isEmpty {
//            cell.logoView.kf.setImage(with: UIImage(named: station.favicon))
            cell.logoView.backgroundColor = .black
            print(station.favicon)
            cell.logoView.image = UIImage(systemName: station.favicon)
        } else {
            cell.logoView.image = UIImage(named: "default_station.jpg")
        }
     
        let fullText = "\(station.country) | \(station.tags)"
        let maxLength = 35
        
        cell.detailLabel?.text = fullText.count > maxLength ? String(fullText.prefix(maxLength)) + "..." : fullText
        cell.stationName?.text = station.name
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        // Check if this cell's station is the active station
        if station.stationuuid == RTDatabaseManager.shared.activeStation?.stationuuid {
            cell.cellContentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)  // Highlight color
            previouslySelectedIndexPath = indexPath
            RTDatabaseManager.shared.activeStation = station
            if RTAudioPlayer.shared.playerState == .playing {
                cell.animationView.play()
            }
            else {
                cell.animationView.stop()
            }
          
        } else {
            cell.cellContentView.backgroundColor = UIColor.clear
            cell.animationView.stop()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let previousIndexPath = previouslySelectedIndexPath {
            let activeStation = RTDatabaseManager.shared.activeStation
            let isNotPlaying = RTAudioPlayer.shared.playerState != .playing
            let station = favoriteStations[previousIndexPath.row]
            if previousIndexPath == indexPath, activeStation?.stationuuid == station.stationuuid , isNotPlaying {

                playRadioStation(station: station)
                RTLastPlayedStationManager.saveLastPlayedStation(station)
                return
            }
            
        }
           
        if let previousIndexPath = previouslySelectedIndexPath,
           let previousCell = tableView.cellForRow(at: previousIndexPath) as? RTFavoriteStationCell {
            UIView.animate(withDuration: 0.15, animations: {
                previousCell.cellContentView.transform = CGAffineTransform.identity
                previousCell.cellContentView.backgroundColor = UIColor.clear
                if RTAudioPlayer.shared.playerState == .playing {
                    previousCell.animationView.play()
                } else {
                    previousCell.animationView.stop()
                }
                
            })
        }
        
        // Handle the newly selected cell
        guard let cell = tableView.cellForRow(at: indexPath) as? RTFavoriteStationCell else { return }
        
        UIView.animate(withDuration: 0.15, animations: {
            // Scale up the contentView
            cell.cellContentView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                // Scale back down
                cell.cellContentView.transform = CGAffineTransform.identity
                cell.cellContentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            }
        }
        
        // Store the current indexPath as previously selected for next time
        previouslySelectedIndexPath = indexPath
        
        
        let station = favoriteStations[indexPath.row]
        currentStation = station
        if RTAudioPlayer.shared.currentURL == station.url {
            // the same, set the button's state
            if RTAudioPlayer.shared.playerState == .playing {
                playerWidget.playButton.isSelected = true
            } else {
                playerWidget.playButton.isSelected = false
            }
        } else {
            
            playRadioStation(station: station)
            RTLastPlayedStationManager.saveLastPlayedStation(station)
        }
        
        
        favoriteTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    private func playRadioStation (station: Station) {
        RTAudioPlayer.shared.playWith(url: station.url)
        RTAudioPlayer.shared.delegate = self
        playerWidget.station = station
        playerWidget.refreshState(station: station)
        playerWidget.playButton.isSelected = true
        playerWidget.isHidden = false
        RTDatabaseManager.shared.activeStation = station
    }
    
    
}

// MARK: - handle favorite button press
extension RTFavoriteViewController: RTFavoriteStationCellDelegate {
    
    func didPressFavoriteButton(at indexPath: IndexPath, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let station = self.favoriteStations[indexPath.row]
            RTDatabaseManager.shared.deleteFavoriteByUUID(stationUUID: station.stationuuid)
            
            DispatchQueue.main.async {
                if self.previouslySelectedIndexPath == indexPath {
                    // Reset the previouslySelectedIndexPath
                    self.previouslySelectedIndexPath = nil
                }
                self.favoriteStations.remove(at: indexPath.row)
                self.favoriteTableView.performBatchUpdates({
                    self.favoriteTableView.deleteRows(at: [indexPath], with: .fade)
                }, completion: { _ in
                    self.updateEmptyStateUI()
                    self.favoriteTableView.reloadData()
                    self.playerWidget.checkIfStationIsFavorite()
                    completion()
                    
                })
            }
        }
    }
    
}


extension RTFavoriteViewController: RTAudioPlayerDelegate {
    
    func playerStateDidChanged(state: STKAudioPlayerState) {
        
        if state == .playing {
            SVProgressHUD.dismiss()
            playerWidget.playButton.isSelected = true
            playerWidget.saveButton.isEnabled = true
            playerWidget.playButton.isEnabled = true
            
        } else if state == .buffering {
            SVProgressHUD.show()
            playerWidget.saveButton.isEnabled = false
            playerWidget.playButton.isEnabled = false
            
        } else if state == .error {
            SVProgressHUD.dismiss()
            playerWidget.playButton.isSelected = false
            playerWidget.saveButton.isEnabled = false
            playerWidget.playButton.isEnabled = false
            SVProgressHUD.showError(withStatus: "load error")
           
        
        } else {
            playerWidget.playButton.isSelected = false
            playerWidget.saveButton.isEnabled = true
            playerWidget.playButton.isEnabled = true
           
            
        }
    }
    
}


extension RTFavoriteViewController: RTPlayingViewControllerDelegate {
    func controllerDidClosed(station: Station?) {
    }
    
    func clickIconImageView(station: Station?) {
        guard let station = station else { return }
        pushToPlayingController(station: station)
    }
    fileprivate func pushToPlayingController(station: Station) {
        let playingVC = UIStoryboard.init(name: "RTPlayingViewController", bundle: nil).instantiateInitialViewController() as! RTPlayingViewController
        playingVC.station = station
        playingVC.delegate = self
        playingVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playingVC, animated: true)
    }
}
