//
//  RTDatabaseManager.swift
//  RadiantTune
//
//  Created by Aaribna Gurung on 5/30/24.
//

import Foundation
import SQLite3


class RTDatabaseManager {
    static let shared = RTDatabaseManager()
    var db: OpaquePointer?
    
    init() {
        openDatabase()
        createTable()
        initializeDatabaseIfNeeded()
    }
    
    func dummyDataFavorites() -> [RTFavoriteModel] {
        return [
            RTFavoriteModel(imageName: "chum", stationName: "CHUM 104.5", location: "Canada", genre: "Pop, Rock, Alternative"),
            RTFavoriteModel(imageName: "q107", stationName: "Q107 Toronto", location: "Canada", genre: "Pop, Rock, Alternative"),
            RTFavoriteModel(imageName: "boom", stationName: "BOOM 101.9", location: "Canada", genre: "Today's Hits!"),
            RTFavoriteModel(imageName: "indie", stationName: "INDIE 88", location: "Canada", genre: "Indie...")
        ]
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imageName TEXT,
        stationName TEXT,
        location TEXT,
        genre TEXT);
        """
        
        if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    
    func insertFavorite(station: RTFavoriteModel) {
        let insertQuery = "INSERT INTO Favorites (imageName, stationName, location, genre) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (station.imageName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (station.stationName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (station.location as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (station.genre as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted favorite.")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure inserting favorite: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("prepare failed: \(errmsg)")
        }
        sqlite3_finalize(insertStatement)
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
    
    func initializeDatabaseIfNeeded() {
        if isDatabaseEmpty() {
            let defaultFavorites = self.dummyDataFavorites()
            for favorite in defaultFavorites {
                self.insertFavorite(station: favorite)
            }
        }
    }
    
    func fetchFavorites() -> [RTFavoriteModel] {
        let query = "SELECT id, imageName, stationName, location, genre FROM Favorites;"
        var queryStatement: OpaquePointer? = nil
        var favorites: [RTFavoriteModel] = []
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let imageName = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let stationName = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let location = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let genre = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                
                let station = RTFavoriteModel(id: Int(id), imageName: imageName, stationName: stationName, location: location, genre: genre)
                favorites.append(station)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing fetch: \(errmsg)")
        }
        sqlite3_finalize(queryStatement)
        
        return favorites
    }

    
    func addFavorite(station: RTFavoriteModel) {
        let insertStatementString = "INSERT INTO Favorites (imageName, stationName, location, genre) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (station.imageName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (station.stationName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (station.location as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (station.genre as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func deleteFavoriteById(id: Int) {
        let deleteStatementString = "DELETE FROM Favorites WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))  // Bind the integer id to the statement
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted favorite with id \(id).")
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
                print("Successfully deleted all favorites.")
            } else {
                print("Could not delete favorites.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
}

