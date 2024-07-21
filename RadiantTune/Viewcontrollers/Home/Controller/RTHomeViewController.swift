//
//  RTHomeViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit
import Kingfisher
import Moya

class RTHomeViewController: RTBaseViewController {

    let kHomeCellID = "RTHomeCollectionViewCell"
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var stationSearch: UISearchBar!
    @IBOutlet weak var playerWidget: RTPlayerWidgetView!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedFilter: SearchFilterType = SearchFilterType.radioStations
    
    var stations = [Station]()
    var isFilterSelected: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let station = RTDatabaseManager.shared.activeStation {
            playerWidget.station = station
            playerWidget.refreshState(station: station)
            playerWidget.isHidden = false
        } else {
            playerWidget.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        setupUI()
        stationSearch.delegate = self
        stationSearch.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerWidget.refreshState(station: nil)
    }
    
    
    fileprivate func setupUI() {
        // collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "RTHomeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: kHomeCellID)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (kScreenWidth - 20)/3, height: (kScreenWidth - 15)/3)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 60, left: 5, bottom: 150, right: 5)
       
        setupPlayerWidgetConstraints(in: self, playerWidget: playerWidget)
        // widget View
        playerWidget.delegate = self
        
        updateFilterButtonAppearance()
        
    }
    
    fileprivate func refreshData() {
        SVProgressHUD.show()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        guard let url = URL(string: "https://de1.api.radio-browser.info/json/stations/bycountry/Canada?limit=40") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request) { data, res, error in
            SVProgressHUD.dismiss()
            if let data = data {
                do {
                    self.stations = try JSONDecoder().decode([Station].self, from: data)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    
                }

            }
            
            if error != nil {
                SVProgressHUD.dismiss()
            }
        }
        
        task.resume()
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Search Options", message: "Choose search type", preferredStyle: .actionSheet)
        
        let searchByStationsAction = UIAlertAction(title: Search.SearchByStationsText, style: .default) { _ in
            // Handle search by radio stations
            self.stationSearch.placeholder = Search.SearchByStationsText
            self.selectedFilter = .radioStations
            self.isFilterSelected = true
            self.updateFilterButtonAppearance()
        }
        
        let searchByCountryAction = UIAlertAction(title: Search.SearchByCountryText, style: .default) { _ in
            self.stationSearch.placeholder = Search.SearchByCountryText
            self.selectedFilter = .country
            self.isFilterSelected = true
            self.updateFilterButtonAppearance()
        }
        
        let searchByTagsAction = UIAlertAction(title: Search.SearcyByTagText, style: .default) { _ in
            // Handle search by tags/genre
            self.stationSearch.placeholder = Search.SearcyByTagText
            self.selectedFilter = .tagsGenre
            self.isFilterSelected = true
            self.updateFilterButtonAppearance()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isFilterSelected = false
            self.updateFilterButtonAppearance()
        }
        
        alertController.addAction(searchByStationsAction)
        alertController.addAction(searchByCountryAction)
        alertController.addAction(searchByTagsAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFilterButtonAppearance() {
        if isFilterSelected {
            filterButton.tintColor = .systemBlue
        } else {
            filterButton.tintColor = .gray
        }
    }

}

extension RTHomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Search suggestions here maybe
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        
        guard let searchViewController = storyboard.instantiateViewController(withIdentifier: "search") as? SearchViewController else {
            //print("search storyboard not found")
            return
        }
        
        searchViewController.searchString = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased()
        searchViewController.selectedFilter = selectedFilter
        searchViewController.modalPresentationStyle = .fullScreen
        searchViewController.delegate = self
        self.present(searchViewController, animated: true, completion: nil)
        
      searchBar.text = ""
        searchBar.showsCancelButton = false
      searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    

}


//MARK:- CollectionViewDelegate
extension RTHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kHomeCellID, for: indexPath) as! RTHomeCollectionViewCell
        let station = stations[indexPath.row]
        cell.iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
        cell.nameLabel.text = station.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let station = stations[indexPath.row]
        pushToPlayingController(station: station)

    }
    
}

//MARK:- RTPlayingViewControllerDelegate
extension RTHomeViewController: RTPlayingViewControllerDelegate {
    func controllerDidClosed(station: Station?) {
        playerWidget.station = station
        playerWidget.refreshState(station: station)
        RTDatabaseManager.shared.activeStation = station
    }
}

//MARK:- RTPlayerWidgetViewDelegate
extension RTHomeViewController: RTPlayerWidgetViewDelegate {
    func clickIconImageView(station: Station?) {
        guard let station = station else { return }
        pushToPlayingController(station: station)
    }
}

//MARK:- private M
extension RTHomeViewController {
    fileprivate func pushToPlayingController(station: Station) {
        let playingVC = UIStoryboard.init(name: "RTPlayingViewController", bundle: nil).instantiateInitialViewController() as! RTPlayingViewController
        playingVC.station = station
        playingVC.delegate = self
        playingVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(playingVC, animated: true)
    }
}

//MARK:- Search VC Delegate
extension RTHomeViewController: SearchViewControllerDelegate {
    func rearchControllerDidClosed(station: Station?) {
        guard let station = station else {
            print("No station selected")
            return
        }
        playerWidget.station = station
        playerWidget.refreshState(station: station)
        RTDatabaseManager.shared.activeStation = station
        
    }
}

