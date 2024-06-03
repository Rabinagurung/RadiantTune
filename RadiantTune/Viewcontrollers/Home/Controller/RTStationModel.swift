//
//  RTStationModel.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-05-28.
//

import Foundation


struct Station: Codable {
    var changeuuid: String
    var stationuuid: String
    var name: String
    var url: String
    var favicon: String
    var country: String
    var language: String
    var tags: String
    
}
