//
//  RTRadioAPI.swift
//  RadiantTune
//
//  Created by Elvis Nguyen on 2024-06-06.
//

import Foundation
import Alamofire
import Moya

enum RadioAPI {
    case getMirrors
    case searchStations (codec: String?, order: String?, reverse: Bool?, limit: Int?)
    case searchbyname (searchTerm: String)
    case searchByCountry (searchTerm: String)
    case searchByTags(searchTerm: String)
}

extension RadioAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://de1.api.radio-browser.info") ?? URL(string: "https://nl1.api.radio-browser.info")!
    }
        
    var path: String {
        switch self {
        case .getMirrors:
                return "/json/servers"
        case .searchStations:
            return "/json/stations/search"
        case .searchbyname(let searchTerm):
            return "/json/stations/byname/\(searchTerm)"
        case .searchByCountry(let searchTerm):
            return "/json/stations/bycountry/\(searchTerm)"
        case .searchByTags(let searchTerm):
            return "/json/stations/bytag/\(searchTerm)"
        }
        
        
    }
    
    var method: Moya.Method {
        switch self {
        case .getMirrors, .searchStations, .searchbyname , .searchByCountry, .searchByTags:
                return .get
            }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMirrors:
            return .requestPlain
        case .searchStations(let codec, let order, let reverse, let limit):
            var params: [String: Any] = [:]
            if let codec = codec {
                params["codec"] = codec
            }
            if let order = order {
                params["order"] = order
            }
            if let reverse = reverse {
                params["reverse"] = reverse
            }
            if let limit = limit {
                params["limit"] = limit
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .searchbyname, .searchByCountry, .searchByTags:
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
                return ["User-Agent": "RadiantTune/0.1",
                        "Accept": "*/*",
                        "Accept-Encoding": "gzip, deflate, br",
                        "Connection": "keep-alive",
                        "Host": "de1.api.radio-browser.info"]
    }
    
    
}
