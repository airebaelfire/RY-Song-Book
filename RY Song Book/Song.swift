//
//  Song.swift
//  RY Song Book
//
//  Created by Zayn Noureddin on 2023-07-28.
//

import Foundation
import CloudKit

struct Song: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var title: String = ""
    var origin: String = ""
    var song: String = ""
    var capo: Int64 = 0
    var strummingpattern: String = ""
    // D----DUDU
}

class Songs: ObservableObject {
    @Published var list: [Song] = []
    
    func refresh(private: Bool = false) {
        CKSong.get(songs: self, _private: `private`)
    }
}

class CKSong {
    static let puDatabase = CKContainer.default().publicCloudDatabase
    static let prDatabase = CKContainer.default().privateCloudDatabase
    
    class func fetch(_private: Bool = false, completion: @escaping (Result<[Song], Error>) -> ()) {
        let predicate = NSPredicate(value: true)
        let title = NSSortDescriptor(key: "title", ascending: true)
        let query = CKQuery(recordType: "Song", predicate: predicate)
        query.sortDescriptors = [title]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "origin", "song", "capo", "strummingpattern"]
        operation.resultsLimit = 1000
        
        var newSongs = [Song]()
        
        operation.recordMatchedBlock = { (id, result) in
            switch result {
                case .success(let record):
                    var song = Song()
                    song.recordID = record.recordID
                    song.title = record["title"] as! String
                    song.origin = record["origin"] as! String
                    song.song = record["song"] as? String ?? ""
                    song.capo = record["capo"] as! Int64
                    song.strummingpattern = record["strummingpattern"] as? String ?? ""
                    newSongs.append(song)
                case .failure(let error):
                    print(error)
            }
        }
        
        operation.queryResultBlock = { (result) in
            switch result {
                case .success(_):
                    completion(.success(newSongs))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        (_private ? prDatabase : puDatabase).add(operation)
    }
    
    class func append(record: CKRecord) {
        prDatabase.save(record) { record, error in
            if error != nil {
                print("Error 202")
                return
            }
            print("Success")
        }
    }
    
    class func get(songs: Songs, _private: Bool) {
        CKSong.fetch(_private: _private) { (results) in
            switch results {
                case .success(let newSongs):
                    songs.list = newSongs
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    class func delete(song: Song) {
        prDatabase.delete(withRecordID: song.recordID!) { (ckRecordID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let id = ckRecordID else {
                return
            }
            print(id)
        }
    }
}
