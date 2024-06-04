//
//  RTFavoriteViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit

class RTFavoriteViewController: RTBaseViewController {
    
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var trashUIButton: UIButton!
    
    var emptyLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var  favoriteStations: [RTFavoriteModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the default Red navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoadingIndicator()
        initialSetup()
        addEmptyLabel()
        
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
        DispatchQueue.global(qos: .userInitiated).async {
            let favorites = RTDatabaseManager.shared.fetchFavorites()
            let delayTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
    
    private func deleteAllFavorites() {

        DispatchQueue.global(qos: .userInitiated).async {
            RTDatabaseManager.shared.deleteAllFavorites()
            DispatchQueue.main.async {
                // Remove all items from the data source
                self.favoriteStations.removeAll()
                // Update the table view
                self.favoriteTableView.reloadData()
                self.updateEmptyStateUI()
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
        
        cell.logoView?.image = UIImage(named: station.imageName)
        
        let fullText = "\(station.location) | \(station.genre)"
        let maxLength = 35
        
        cell.detailLabel?.text = fullText.count > maxLength ? String(fullText.prefix(maxLength)) + "..." : fullText
        cell.stationName?.text = station.stationName
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        favoriteTableView.deselectRow(at: indexPath, animated: true)
    }
    

   
}

// MARK: - handle favorite button press
extension RTFavoriteViewController: RTFavoriteStationCellDelegate {

    func didPressFavoriteButton(at indexPath: IndexPath, completion: @escaping () -> Void) {
       
        DispatchQueue.global(qos: .userInitiated).async {
            let station = self.favoriteStations[indexPath.row]
            RTDatabaseManager.shared.deleteFavoriteById(id: station.id!)
            
            DispatchQueue.main.async {
                
                self.favoriteStations.remove(at: indexPath.row)
                self.favoriteTableView.performBatchUpdates({
                    self.favoriteTableView.deleteRows(at: [indexPath], with: .fade)
                }, completion: { _ in
                    self.updateEmptyStateUI()
                    self.favoriteTableView.reloadData()
                    completion()
                
                })
            }
        }
    }
    

}
