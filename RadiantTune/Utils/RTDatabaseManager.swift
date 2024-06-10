//
//  RTDatabaseManager.swift
//  RadiantTune
//
//  Created by Aaribna Gurung on 5/30/24.
//

import Foundation
import SQLite3


protocol RTDatabaseManagerDelegate: AnyObject {
    func didChangeActiveStation(to newStation: Station?)
}

class RTDatabaseManager {
    static let shared = RTDatabaseManager()
    weak var delegate: RTDatabaseManagerDelegate?
    
    var db: OpaquePointer?
    
    var activeStation: Station? {
        didSet {
            if let newStation = activeStation {
                delegate?.didChangeActiveStation(to: newStation)
            }
        }
    }
    
    
    var favoriteStationUUIDs = Set<String>()
    
    init() {
        
        openDatabase()
        createTable()
        
    }
    
    
    
    func openDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("RadiantTune.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }
    
    func createTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS Favorites(
            changeuuid TEXT,
            stationuuid TEXT PRIMARY KEY,
            name TEXT,
            url TEXT,
            favicon TEXT,
            country TEXT,
            language TEXT,
            tags TEXT
            );
            """
        
        if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func dropFavoritesTable() {
        let dropTableString = "DROP TABLE IF EXISTS Favorites;"
        var dropStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, dropTableString, -1, &dropStatement, nil) == SQLITE_OK {
            if sqlite3_step(dropStatement) == SQLITE_DONE {
                print("Favorites table successfully dropped.")
            } else {
                print("Could not drop Favorites table.")
            }
        } else {
            print("DROP TABLE statement could not be prepared.")
        }
        sqlite3_finalize(dropStatement)
    }
    
    
    
    func isDatabaseEmpty() -> Bool {
        let countQuery = "SELECT COUNT(*) FROM Favorites;"
        var queryStatement: OpaquePointer? = nil
        var isEmpty = true
        
        if sqlite3_prepare_v2(db, countQuery, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let count = sqlite3_column_int(queryStatement, 0)
                isEmpty = count == 0
            }
            sqlite3_finalize(queryStatement)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing count query: \(errmsg)")
        }
        
        return isEmpty
    }
    
    func fetchFavorites() -> [Station] {
        let query = "SELECT  changeuuid, stationuuid, name, url, favicon, country, language, tags FROM Favorites;"
        var queryStatement: OpaquePointer? = nil
        var favorites: [Station] = []
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                
                guard let changeuuidCStr = sqlite3_column_text(queryStatement, 0),
                      let stationuuidCStr = sqlite3_column_text(queryStatement, 1),
                      let urlCStr = sqlite3_column_text(queryStatement, 3),
                      let languageCStr = sqlite3_column_text(queryStatement, 6) else {
                    continue
                }
                
                let changeuuid = String(cString: changeuuidCStr)
                let stationuuid = String(cString: stationuuidCStr)
                let name = String(cString: sqlite3_column_text(queryStatement, 2)!)
                let url = String(cString: urlCStr)
                let favicon = String(cString: sqlite3_column_text(queryStatement, 4)!)
                let country = String(cString: sqlite3_column_text(queryStatement, 5)!)
                let language = String(cString: languageCStr)
                let tags = String(cString: sqlite3_column_text(queryStatement, 7)!)
                
                
                let station = Station(
                    changeuuid: changeuuid,
                    stationuuid: stationuuid,
                    name: name,
                    url: url,
                    favicon: favicon,
                    country: country,
                    language: language,
                    tags: tags
                )
                favorites.append(station)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing fetch: \(errmsg)")
        }
        sqlite3_finalize(queryStatement)
        
        return favorites
    }
    
    
    
    func addFavorite(station: Station) {
        let insertStatementString = """
    INSERT INTO Favorites (changeuuid, stationuuid, name, url, favicon, country, language, tags)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (station.changeuuid as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (station.stationuuid as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (station.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (station.url as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (station.favicon as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (station.country as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (station.language as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, (station.tags as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                favoriteStationUUIDs.insert(station.stationuuid)
                print("Successfully inserted favorite.")
            } else {
                print("Could not insert row. Error: \(String(describing: sqlite3_errmsg(db)))")
            }
        } else {
            print("INSERT statement could not be prepared. Error: \(String(describing: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func deleteFavoriteByUUID(stationUUID: String) {
        let deleteStatementString = "DELETE FROM Favorites WHERE stationuuid = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (stationUUID as NSString).utf8String, -1, nil)  // Bind the string stationUUID to the statement
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                removeFromFavorites(uuid: stationUUID)
                print("Successfully deleted favorite with stationUUID \(stationUUID).")
                
            } else {
                print("Could not delete favorite.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    
    func deleteAllFavorites() {
        let deleteStatementString = "DELETE FROM Favorites;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                emptyFavoriteUUIDs()
                print("Successfully deleted all favorites.")
            } else {
                print("Could not delete favorites.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func populateFavoriteUUIDs() {
        let query = "SELECT stationuuid FROM Favorites;"
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                if let stationuuidCStr = sqlite3_column_text(queryStatement, 0) {
                    let uuid = String(cString: stationuuidCStr)
                    favoriteStationUUIDs.insert(uuid)
                }
                
            }
            sqlite3_finalize(queryStatement)
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Error preparing fetch: \(errmsg)")
        }
    }
    
    func isFavoriteStation(uuid: String) -> Bool {
        return favoriteStationUUIDs.contains(uuid)
    }
    
    func removeFromFavorites(uuid: String)  {
        if favoriteStationUUIDs.contains(uuid) {
            favoriteStationUUIDs.remove(uuid)
        }
    }
    
    func emptyFavoriteUUIDs() {
        favoriteStationUUIDs.removeAll()
    }
}

