//
//  SearchViewController.swift
//  RadiantTune
//
//  Created by Elvis Nguyen on 2024-06-09.
//

import Foundation
import UIKit
import Moya
import Kingfisher

enum SearchFilterType {
    case radioStations
    case tagsGenre
    case country
}
protocol SearchViewControllerDelegate {
    func rearchControllerDidClosed(station: Station?)
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    var selectedFilter: SearchFilterType?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    var delegate: SearchViewControllerDelegate?
    var station: Station?
    
    var searchString: String?
    var stations = [APIStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchBar.delegate = self
        
        //Support dark mode
        customizeSearchBar()
        
        searchBar.resignFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        
        //searchTableView.estimatedRowHeight = 150
        searchTableView.register(UINib(nibName: "RTSearchStationTableViewCell", bundle: nil), forCellReuseIdentifier: "RTSearchStationTableViewCell")
        
        if let searchString = searchString {
            searchBar.text = searchString
            //debugPrint("Recieved \(searchString) from Homepage search")
            if selectedFilter == .radioStations {
                searchbyname(searchString: searchString)
                searchBar.placeholder = Search.SearchByStationsText
            } 
            else if selectedFilter == .country {
                searchByCountry(searchString: searchString)
                searchBar.placeholder = Search.SearchByCountryText
            }
                else {
                searchByGenre(searchString: searchString)
                searchBar.placeholder = Search.SearcyByTagText
            }
         
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // if the player is playing it should call the delegate to refresh the widget
        if RTAudioPlayer.shared.playerState == .playing {
            delegate?.rearchControllerDidClosed(station: station)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        //UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "RTSearchStationTableViewCell", for: indexPath) as! RTSearchStationTableViewCell
        let station = stations[indexPath.row]
        
        cell.lblStationName.text = station.name
        cell.backgroundColor = .systemBackground
        
        if let faviconURL = station.favicon {
            let url = URL(string: faviconURL)
            cell.imgStationFavicon.kf.setImage(with: url, placeholder: UIImage(named: "default_station.jpg"))
        }
        else {
            cell.imgStationFavicon.image = UIImage(named: "default_station.jpg")
        }
            
        return cell
    }
    
    //Adapter to make APIStation work with Station
    func convertToStation (apiStation: APIStation) -> Station? {
        
        guard let name = apiStation.name else { return nil }
        guard let url = apiStation.url else { return nil }
        
        return Station (
            changeuuid: apiStation.changeuuid ?? "",
            stationuuid: apiStation.stationuuid ?? "",
            name: name,
            url: url,
            favicon: apiStation.favicon ?? "",
            country: apiStation.country ?? "",
            language: apiStation.language ?? "",
            tags: apiStation.tags ?? ""
        )
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(stations[indexPath.row].name ?? "Station click not detected")")
        
        guard let playingVC = UIStoryboard.init(name: "RTPlayingViewController", bundle: nil).instantiateInitialViewController() as? RTPlayingViewController else {
            print("Unable to instantiate RTPlayingViewController at search item interaction")
            return
        }
        //print("VC Instantiation success")
        
        
        guard let station = convertToStation(apiStation: stations[indexPath.row]) else {
            print("Unable to convert APIStation struct to Station")
            return }
        //print("Adapter conversion success")
        playingVC.delegate = self
        playingVC.station = station
        playingVC.hidesBottomBarWhenPushed = true
        playingVC.modalPresentationStyle = .formSheet
        tableView.deselectRow(at: indexPath, animated: false)
        self.present(playingVC, animated: true)
        //self.navigationController?.pushViewController(playingVC, animated: true)
        //print("navigation launched")
    }
    
    func searchbyname(searchString: String) {
        //debugPrint("Seaching by name: \(searchString)")
        let moya = MoyaProvider<RadioAPI>()
        moya.request(RadioAPI.searchbyname(searchTerm: searchString.lowercased())) { result in
            self.handleSearchResult(result, searchString: searchString)
        }
    }
    
    func searchByCountry(searchString: String) {
        //debugPrint("Seaching by country: \(searchString)")
        let moya = MoyaProvider<RadioAPI>()
        moya.request(RadioAPI.searchByCountry(searchTerm: searchString.lowercased())) { result in
            self.handleSearchResult(result, searchString: searchString)
        }
    }
    
    func searchByGenre(searchString: String) {
        //debugPrint("Seaching by tag: \(searchString)")
        let moya = MoyaProvider<RadioAPI>()
        moya.request(RadioAPI.searchByTags(searchTerm: searchString.lowercased())) { result in
            //debugPrint(result)
            self.handleSearchResult(result, searchString: searchString)
        }
    }
    func handleSearchResult(_ result: Result<Response, MoyaError>, searchString: String) {
        switch result {
        case let .success(moyaResponse):
            do {
                let decoder = JSONDecoder()
                self.stations = try decoder.decode([APIStation].self, from: moyaResponse.data)
                debugPrint(try moyaResponse.filterSuccessfulStatusCodes().mapString())
                if self.stations.isEmpty {
                    let station = APIStation(
                        changeuuid: "",
                        stationuuid: "",
                        serveruuid: "",
                        name: "No stations found for \(searchString)",
                        url: nil,
                        urlResolved: "",
                        homepage: "",
                        favicon: "",
                        tags: "radio,music",
                        country: "Canada",
                        countrycode: "CA",
                        iso3166_2: nil,
                        state: "Ontario",
                        language: "English",
                        languagecodes: "en",
                        votes: 100,
                        lastchangetime: "2024-06-09T00:00:00Z",
                        lastchangetimeIso8601: "2024-06-09T00:00:00Z",
                        codec: .aac,
                        bitrate: 128000,
                        hls: 1,
                        lastcheckok: 1,
                        lastchecktime: "2024-06-09T08:00:00Z",
                        lastchecktimeIso8601: "2024-06-09T08:00:00Z",
                        lastcheckoktime: "2024-06-09T08:00:00Z",
                        lastcheckoktimeIso8601: "2024-06-09T08:00:00Z",
                        lastlocalchecktime: nil,
                        lastlocalchecktimeIso8601: nil,
                        clicktimestamp: nil,
                        clicktimestampIso8601: nil,
                        clickcount: nil,
                        clicktrend: nil,
                        sslError: 0,
                        geoLat: 7.1569,
                        geoLong: -9.3872,
                        hasExtendedInfo: false
                    )
                    self.stations.append(station)
                }
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            } catch {
                print(error)
            }
        case let .failure(error):
            print(error.localizedDescription)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchBar.text
        //Search suggestions here maybe
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchString = searchString {
            if selectedFilter == .radioStations {
                searchbyname(searchString: searchString)
            }else if selectedFilter == .country {
                searchByCountry(searchString: searchString)
            }
            else if selectedFilter == .tagsGenre {
                searchByGenre(searchString: searchString)
            }
          
        }
        searchBar.showsCancelButton = true
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        dismiss(animated: true)
    }
    
    private func customizeSearchBar() {
        searchBar.barTintColor = .systemBackground
        searchBar.backgroundColor = .systemBackground
        searchBar.tintColor = .systemBackground
        searchBar.searchTextField.backgroundColor = .systemBackground
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.tintColor = .systemBackground
            cancelButton.setTitleColor(.systemBlue, for: .normal)
        }
        
    }
}

extension SearchViewController : RTPlayingViewControllerDelegate {
    func controllerDidClosed(station: Station?) {
        self.station = station
        
    }
}
