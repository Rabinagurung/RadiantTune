//
//  RTAPIStation.swift
//  RadiantTune
//
//  Created by Elvis Nguyen on 2024-06-09.
//

import Foundation


struct APIStation: Codable {
    let changeuuid: String?
    let stationuuid: String?
    let serveruuid: String?
    let name: String?
    let url: String?
    let urlResolved: String?
    let homepage: String?
    let favicon: String?
    let tags: String?
    let country: String?
    let countrycode: String?
    let iso3166_2: ISO3166_2?
    let state: String?
    let language: String?
    let languagecodes: String?
    let votes: Int?
    let lastchangetime: String?
    let lastchangetimeIso8601: String?
    let codec: Codec?
    let bitrate: Int?
    let hls: Int?
    let lastcheckok: Int?
    let lastchecktime: String?
    let lastchecktimeIso8601: String?
    let lastcheckoktime: String?
    let lastcheckoktimeIso8601: String?
    let lastlocalchecktime: String?
    let lastlocalchecktimeIso8601: String?
    let clicktimestamp: String?
    let clicktimestampIso8601: String?
    let clickcount: Int?
    let clicktrend: Int?
    let sslError: Int?
    let geoLat: Double?
    let geoLong: Double?
    let hasExtendedInfo: Bool?

    enum CodingKeys: String, CodingKey {
        case changeuuid
        case stationuuid
        case serveruuid
        case name
        case url
        case urlResolved
        case homepage
        case favicon
        case tags
        case country
        case countrycode
        case iso3166_2
        case state
        case language
        case languagecodes
        case votes
        case lastchangetime
        case lastchangetimeIso8601
        case codec
        case bitrate
        case hls
        case lastcheckok
        case lastchecktime
        case lastchecktimeIso8601
        case lastcheckoktime
        case lastcheckoktimeIso8601
        case lastlocalchecktime
        case lastlocalchecktimeIso8601
        case clicktimestamp
        case clicktimestampIso8601
        case clickcount
        case clicktrend
        case sslError
        case geoLat
        case geoLong
        case hasExtendedInfo
    }
}

enum Codec: String, Codable {
    case aac = "AAC+"
    case aacH264 = "AAC,H.264"
    case codecAac = "AAC"
    case flv = "FLV"
    case mp3 = "MP3"
    case ogg = "OGG"
    case unknown = "UNKNOWN"
}

enum ISO3166_2: String, Codable {
    case deBy = "DE-BY"
}
