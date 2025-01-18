////
////  PersistanceController.swift
////  RY Song Book
////
////  Created by Zayn Noureddin on 2024-05-31.
////
//
//import CoreData
//import CloudKit
//
////class PersistenceController {
////    static let shared = PersistenceController()
////    
////    lazy var container: NSPersistentCloudKitContainer = {
////        let _container = NSPersistentCloudKitContainer(name: "Main")
////        
////        guard let description = _container.persistentStoreDescriptions.first else {
////            fatalError("Failed to retrive a persistence store description.")
////        }
////        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
////        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//////        description.cloudKitContainerOptions?.databaseScope = .public
////        
////        _container.loadPersistentStores(completionHandler: { (_, error) in
////            guard let error = error as NSError? else { return }
////            fatalError("Failed to load persistent stores: \(error)")
////        })
////        
////        _container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
////        _container.viewContext.automaticallyMergesChangesFromParent = true
////        do {
////            try _container.viewContext.setQueryGenerationFrom(.current)
////        } catch {
////            fatalError("Failed to pin viewContext to the current generation:\(error)")
////        }
////        return _container
////    }()
////}
//
//struct PersistenceController {
//    // A singleton for the entire app to use
//    static let shared = PersistenceController()
//    
//    // Storage for Core Data
//    let container: NSPersistentCloudKitContainer
//    
////    // A test configuration for SwiftUI previews
////    static var preview: PersistenceController = {
////        let controller = PersistenceController(inMemory: true)
////
////        for _ in 0..<10 {
////            let song = Song(context: controller.container.viewContext)
////            song.title = "Song 1"
////            song.origin = "Somewhere"
////            song.capo = 0
////            song.strummingpattern = "D-D-DUDU"
////        }
////
////        return controller
////    }()
//    
//    // An initializer to load Core Data, optionally able to use an in-memory store.
//    init(inMemory: Bool = false) {
//        // If you didn't name your model Main you'll need to change this name below.
//        container = NSPersistentCloudKitContainer(name: "Main")
//
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
//        }
//        
//        guard let description = container.persistentStoreDescriptions.first else {
//            fatalError("Failed to retrive a persistence store description.")
//        }
//        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        description.cloudKitContainerOptions?.databaseScope = .public
//
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Error: \(error.localizedDescription)")
//            }
//        }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
//    }
//    
//    func save() {
//        let context = container.viewContext
//
//        if context.hasChanges {
//            do {
//                try context.save()
//                print("Yay!")
//            } catch {
//                print("Oh no!")
//            }
//        }
//    }
//    
//    func delete(_ song: Song) {
//        container.viewContext.perform {
//            self.container.viewContext.delete(song)
//            self.save()
//        }
//    }
//}
