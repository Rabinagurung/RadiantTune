//
//  RTAPIStation.swift
//  RadiantTune
//
//  Created by Elvis Nguyen on 2024-06-09.
//

import Foundation
import OptionallyDecodable // https://github.com/idrougge/OptionallyDecodable

// MARK: - APIStationElement
struct APIStation: Codable {
    let changeuuid, stationuuid, serveruuid, name: String?
    let url: String?
    let urlResolved: String?
    let homepage: String?
    let favicon: String?
    let tags, country, countrycode: String?
    let iso3166_2: JSONNull?
    let state: String?
    @OptionallyDecodable var language: String?
    @OptionallyDecodable var languagecodes: String?
    let votes: Int?
    let lastchangetime: String?
    let lastchangetimeIso8601: String?
    @OptionallyDecodable var codec: Codec?
    let bitrate, hls, lastcheckok: Int?
    let lastchecktime: String?
    let lastchecktimeIso8601: String?
    let lastcheckoktime: String?
    let lastcheckoktimeIso8601: String?
    let lastlocalchecktime: String?
    let lastlocalchecktimeIso8601: String?
    let clicktimestamp: String?
    let clicktimestampIso8601: Date?
    let clickcount, clicktrend, sslError: Int?
    let geoLat, geoLong: Double?
    let hasExtendedInfo: Bool?

    enum CodingKeys: String, CodingKey {
        case changeuuid, stationuuid, serveruuid, name, url
        case urlResolved
        case homepage, favicon, tags, country, countrycode
        case iso3166_2
        case state, language, languagecodes, votes, lastchangetime
        case lastchangetimeIso8601
        case codec, bitrate, hls, lastcheckok, lastchecktime
        case lastchecktimeIso8601
        case lastcheckoktime
        case lastcheckoktimeIso8601
        case lastlocalchecktime
        case lastlocalchecktimeIso8601
        case clicktimestamp
        case clicktimestampIso8601
        case clickcount, clicktrend
        case sslError
        case geoLat
        case geoLong
        case hasExtendedInfo
    }
}

enum Codec: String, Codable {
    case aac = "AAC"
    case codecAAC = "AAC+"
    case mp3 = "MP3"
    case unknown = "UNKNOWN"
}

enum Language: String, Codable {
    case empty = ""
    case english = "english"
    case german = "german"
}

enum Languagecodes: String, Codable {
    case de = "de"
    case empty = ""
    case en = "en"
}


// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }
        
    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}
