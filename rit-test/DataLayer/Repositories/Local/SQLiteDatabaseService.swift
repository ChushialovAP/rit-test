import Foundation
import SQLite3

public final class SqliteDatabaseService {
    // Get the URL to db store file
    let dbURL: URL
    // The database pointer.
    var db: OpaquePointer?
    // Prepared statement https://www.sqlite.org/c3ref/stmt.html to insert an event into Table.
    // we use prepared statements for efficiency and safe guard against sql injection.
    var createTableStmt: OpaquePointer?
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
    
    
    init() {
        do {
            do {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("integration.db")
                print("URL: %s", dbURL.absoluteString)
            } catch {
                
                print("Some error occurred. Returning empty path.")
                dbURL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTable()
        } catch {
            print("Some error occurred. Returning.")
            return
        }
    }
    
    // Command: sqlite3_open(dbURL.path, &db)
    // Open the DB at the given path. If file does not exists, it will create one for you
    func openDB() throws {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK { // error mostly because of corrupt database
            print("error opening database at %s", dbURL.absoluteString)
            //            deleteDB(dbURL: dbURL)
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    func closeDB() {
        sqlite3_close(db)
        print("database connection closed")
    }
    
    // Code to delete a db file. Useful to invoke in case of a corrupt DB and re-create another
    func deleteDB() {
        print("removing db")
        do {
            try FileManager.default.removeItem(at: self.dbURL)
        } catch {
            print("exception while removing db %s", error.localizedDescription)
        }
    }
    
    func createTable() throws {
        let createTableString = """
                                CREATE TABLE IF NOT EXISTS Record
                                (id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT,
                                isHUDEnabled BOOLEAN,
                                distanceCovered REAL)
                                """
        // ID | isHUDEnabled | distanceCovered
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStmt, nil) ==
            SQLITE_OK {
            if sqlite3_step(createTableStmt) == SQLITE_DONE {
                print("\nRecord table created.")
            } else {
                print("\nRecord table is not created.")
            }
        } else {
            print("\nCREATE TABLE statement is not prepared.")
        }
        sqlite3_finalize(createTableStmt)
    }
    
    func insertFullRecord(_ entry: DBRecord) {
        let insertStmtString = """
                                INSERT OR REPLACE INTO Record (id, isHUDEnabled, distanceCovered) VALUES (?, ?, ?);
                                """
        
        if sqlite3_prepare_v2(db, insertStmtString, -1, &insertEntryStmt, nil) ==
            SQLITE_OK {
            let id: Int32 = 1
            
            sqlite3_bind_int(insertEntryStmt, 1, id)
            sqlite3_bind_int(insertEntryStmt, 2, Int32(entry.isHUDEnabled))
            sqlite3_bind_double(insertEntryStmt, 3, entry.distanceCovered)
            if sqlite3_step(insertEntryStmt) == SQLITE_DONE {
                print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertEntryStmt)
    }
    
    func insertDistanceCovered(_ value: Double) {
        let insertStmtString = """
                                INSERT OR REPLACE INTO Record (id, distanceCovered) VALUES (?, ?);
                                """
        
        if sqlite3_prepare_v2(db, insertStmtString, -1, &insertEntryStmt, nil) ==
            SQLITE_OK {
            let id: Int32 = 1
            
            sqlite3_bind_int(insertEntryStmt, 1, id)
            sqlite3_bind_double(insertEntryStmt, 2, value)
            if sqlite3_step(insertEntryStmt) == SQLITE_DONE {
                print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertEntryStmt)
    }
    
    func read() -> DBRecord? {
        let readStmtString = """
                            SELECT * FROM Record
                            """
        
        var isHUDEnabled: Int32
        var distanceCovered: Double
        
        if sqlite3_prepare_v2(db, readStmtString, -1, &readEntryStmt, nil) ==
            SQLITE_OK {
            if sqlite3_step(readEntryStmt) == SQLITE_ROW {
                isHUDEnabled = sqlite3_column_int(readEntryStmt, 1)
                distanceCovered = sqlite3_column_double(readEntryStmt, 2)
                
            } else {
                print("\nQuery returned no results.")
                return nil
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\nQuery is not prepared \(errorMessage)")
            return nil
        }
        sqlite3_finalize(readEntryStmt)
        return DBRecord(isHUDEnabled: isHUDEnabled == 1 ? true : false,
                        distanceCovered: distanceCovered)
    }
}

// Indicates an exception during a SQLite Operation.
class SqliteError : Error {
    var message = ""
    var error = SQLITE_ERROR
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}
