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

/*
 struct RTFavoriteModel  {
     var id: Int?
     var imageName: String
     var stationName: String
     var location: String
     var genre: String

 }
 
 */

//func convertStationToFavorite(station: Station) -> RTFavoriteModel {
//    var favoriteModel = RTFavoriteModel(imageName: station.favicon, stationName: station.name, location: station.country, genre: "default")
//    favoriteModel.id = 23
//    return favoriteModel
//}
