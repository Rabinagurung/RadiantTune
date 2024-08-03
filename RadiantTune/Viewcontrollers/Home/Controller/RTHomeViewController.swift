//
//  RTHomeViewController.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-11.
//

import UIKit
import Kingfisher
import Moya
import CoreLocation

class RTHomeViewController: RTBaseViewController {
    
    let kHomeCellID = "RTHomeCollectionViewCell"
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var stationSearch: UISearchBar!
    @IBOutlet weak var playerWidget: RTPlayerWidgetView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recentlyPlayedCollectionView: UICollectionView!
    
    @IBOutlet weak var Recommendations: UILabel!
    
    var selectedFilter: SearchFilterType = SearchFilterType.radioStations
    
    var stations = [Station]()
    var isFilterSelected: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let station = RTDatabaseManager.shared.activeStation {
            playerWidget.station = station
            playerWidget.refreshState(station: station)
            playerWidget.isHidden = false
        } else {
            playerWidget.isHidden = true
        }
        updateRecentlyPlayedStations()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        setupUI()
        setupLocationManager()
        
        stationSearch.delegate = self
        stationSearch.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        stationSearch.backgroundColor = .systemBackground
        updateRecentlyPlayedStations()
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
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 5, bottom: 150, right: 5)
        
        //recentlyPlayedCollectionView
        recentlyPlayedCollectionView.delegate = self
        recentlyPlayedCollectionView.dataSource = self
        recentlyPlayedCollectionView.register(nib, forCellWithReuseIdentifier: "RecentStationCell")
        let recentLayout = UICollectionViewFlowLayout()
        recentLayout.minimumLineSpacing = 5
        recentLayout.minimumInteritemSpacing = 5
        recentLayout.itemSize = CGSize(width: (recentlyPlayedCollectionView.bounds.width-25)/3, height: (recentlyPlayedCollectionView.bounds.width-15)/3)
        recentlyPlayedCollectionView.collectionViewLayout = recentLayout
        recentlyPlayedCollectionView.backgroundColor = .systemBackground
        
        setupPlayerWidgetConstraints(in: self, playerWidget: playerWidget)
        // widget View
        playerWidget.delegate = self
        
        updateFilterButtonAppearance()
        
        
        print("Collection view frame: \(recentlyPlayedCollectionView.frame)")
        print("Item size: \(recentLayout.itemSize)")
        
    }
    
    fileprivate func refreshData( state: String? = nil) {
        SVProgressHUD.show()
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let baseURL = "https://de1.api.radio-browser.info/json/stations"
        
        var urlString: String
        
        if let state = state, !state.isEmpty {
            urlString = "\(baseURL)/bystate/\(state)?limit=80"
            Recommendations.text = "Stations near \(state)"
        } else {
            Recommendations.text = "Browse Stations"
            urlString = "\(baseURL)/bycountry/Canada?limit=80"
        }
        
        guard let url = URL(string: urlString) else {
                    SVProgressHUD.dismiss()
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
    
    func updateRecentlyPlayedStations() {
        recentlyPlayedCollectionView.reloadData()
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
        filterButton.backgroundColor = .systemBackground
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
        
        searchViewController.searchString = searchBar.text?.lowercased()
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
        
        if collectionView == recentlyPlayedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentStationCell", for: indexPath) as! RTHomeCollectionViewCell
            let recentStations = RTLastPlayedStationManager.loadRecentlyPlayedStations()
            let station = recentStations[indexPath.item]
            cell.iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
            cell.nameLabel.text = station.name
            cell.backgroundColor = .systemBackground
            cell.nameLabel.textColor = .label
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kHomeCellID, for: indexPath) as! RTHomeCollectionViewCell
            let station = stations[indexPath.row]
            cell.iconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(named: "default_station.jpg"))
            cell.nameLabel.text = station.name
            cell.backgroundColor = .systemBackground
            cell.nameLabel.textColor = .label
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentlyPlayedCollectionView {
            return RTLastPlayedStationManager.loadRecentlyPlayedStations().count
        } else {
            return stations.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recentlyPlayedCollectionView {
            let recentStations = RTLastPlayedStationManager.loadRecentlyPlayedStations()
            let station = recentStations[indexPath.item]
            pushToPlayingController(station: station)
        } else {
            let station = stations[indexPath.row]
            pushToPlayingController(station: station)
        }
        
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


extension RTHomeViewController: CLLocationManagerDelegate {
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        reverseGeocodeLocation(location) { city, state, country in
            if let state = state {
                self.refreshData(state: state)
            } else {
                self.refreshData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}


extension RTHomeViewController {
    private func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping (String?, String?, String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                completion(nil, nil, nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil, nil, nil)
                return
            }
            
            let city = placemark.locality
            let state = placemark.administrativeArea
            let country = placemark.country
            
            completion(city, state, country)
        }
    }
}
