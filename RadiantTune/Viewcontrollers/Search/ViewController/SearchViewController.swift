//
//  SearchViewController.swift
//  RadiantTune
//
//  Created by Elvis Nguyen on 2024-06-09.
//

import Foundation
import UIKit
import Moya

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    var searchString: String?
    var stations = [APIStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let searchString = searchString {
            searchBar.text = searchString
            debugPrint("Recieved \(searchString) from Homepage search")
            searchbyname(searchString: searchString)
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
                            let stations = try decoder.decode([Station].self, from: moyaResponse.data)
                            debugPrint(stations)
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
}
