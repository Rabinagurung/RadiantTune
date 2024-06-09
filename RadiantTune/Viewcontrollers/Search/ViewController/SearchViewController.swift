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

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    var searchString: String?
    var stations = [APIStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.rowHeight = UITableView.automaticDimension
        
        searchTableView.estimatedRowHeight = 150
        searchTableView.register(UINib(nibName: "StationTableCell", bundle: nil), forCellReuseIdentifier: "StationTableCell")
        
        
        if let searchString = searchString {
            searchBar.text = searchString
            debugPrint("Recieved \(searchString) from Homepage search")
            searchbyname(searchString: searchString)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "StationTableCell", for: indexPath) as! StationTableCell
        let station = stations[indexPath.row]
        
        cell.lblStationName.text = station.name
        
        if let faviconURL = station.favicon {
            let url = URL(string: faviconURL)
            cell.imgStationFavicon.kf.setImage(with: url, placeholder: UIImage(named: "default_station.jpg"))
        }
        else {
            cell.imgStationFavicon.image = UIImage(named: "default_station.jpg")
        }
            
        return cell
    }
    
    func searchbyname(searchString:String)
    {
        let moya = MoyaProvider<RadioAPI>()
        /*
        moya.request(RadioAPI.searchStations(codec: .none, order: .none, reverse: .none, limit: 1)) */
        moya.request(RadioAPI.searchbyname(searchTerm: "The beat") ) { result in
            switch result {
                case let .success(moyaResponse):
                    do {
                        //try moyaResponse.filterSuccessfulStatusCodes()
                        //let data = try moyaResponse.mapJSON()
                        
                        let decoder = JSONDecoder()
                        self.stations = try decoder.decode([APIStation].self, from: moyaResponse.data)
                        DispatchQueue.main.async {
                            self.searchTableView.reloadData()
                        }
                        /*
                        for station in stations {
                            debugPrint("Name: \(station.name!), Image: \(station.favicon!), URL:\(station.url!)")
                        }*/
                        //debugPrint(stations)
                        //debugPrint(data)
                    }
                    catch {
                        print(error)
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
        }
    }

}
