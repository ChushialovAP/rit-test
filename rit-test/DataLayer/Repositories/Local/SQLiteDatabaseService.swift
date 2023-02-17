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
        print("connection established")
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
                                isHUDEnabled INTEGER,
                                unitsChosen INTEGER,
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
    
    func insertRecord(_ entry: DBRecord) {
        if entry.isHUDEnabled != nil && entry.unitsChosen != nil {
            let insertStmtString = """
                                    INSERT OR REPLACE INTO Record (id, isHUDEnabled, unitsChosen, distanceCovered) VALUES (?, ?, ?, ?);
                                    """
            
            if sqlite3_prepare_v2(db, insertStmtString, -1, &insertEntryStmt, nil) ==
                SQLITE_OK {
                let id: Int32 = 1
                
                sqlite3_bind_int(insertEntryStmt, 1, id)
                sqlite3_bind_int(insertEntryStmt, 2, Int32(entry.isHUDEnabled!))
                sqlite3_bind_int(insertEntryStmt, 3, Int32(entry.unitsChosen!))
                sqlite3_bind_double(insertEntryStmt, 4, entry.distanceCovered)
                if sqlite3_step(insertEntryStmt) == SQLITE_DONE {
                    print("\nSuccessfully inserted row.")
                } else {
                    print("\nCould not insert row.")
                }
            } else {
                print("\nINSERT statement is not prepared.")
            }
            sqlite3_finalize(insertEntryStmt)
        } else {
            let updateStmtString = """
                                    UPDATE Record SET distanceCovered = \(entry.distanceCovered) WHERE id = 1;
                                    """
            
            if sqlite3_prepare_v2(db, updateStmtString, -1, &updateEntryStmt, nil) ==
                SQLITE_OK {
    
                if sqlite3_step(updateEntryStmt) == SQLITE_DONE {
                    print("\nSuccessfully updated row.")
                } else {
                    print("\nCould not update row.")
                }
            } else {
                print("\nUPDATE statement is not prepared.")
            }
            sqlite3_finalize(updateEntryStmt)
        }
    }
    
    func read() -> DBRecord? {
        let readStmtString = """
                            SELECT * FROM Record
                            """
        
        var isHUDEnabled: Int32
        var unitsChosen: Int32
        var distanceCovered: Double
        
        if sqlite3_prepare_v2(db, readStmtString, -1, &readEntryStmt, nil) ==
            SQLITE_OK {
            if sqlite3_step(readEntryStmt) == SQLITE_ROW {
                isHUDEnabled = sqlite3_column_int(readEntryStmt, 1)
                unitsChosen = sqlite3_column_int(readEntryStmt, 2)
                distanceCovered = sqlite3_column_double(readEntryStmt, 3)
                
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
                        unitsChosen: Int(unitsChosen),
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
