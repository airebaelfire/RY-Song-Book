//
//  RY_Song_BookApp.swift
//  RY Song Book
//
//  Created by Zayn Noureddin on 2023-07-28.
//

import SwiftUI

@main
struct RY_Song_BookApp: App {
//    let persistenceController = PersistenceController.shared
    let songs = Songs()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(songs)
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

extension FileManager {
    func getListFileNameInBundle(bundlePath: String) -> [String] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: Bundle.main.bundleURL.appendingPathComponent(bundlePath), includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            return contents.map{$0.lastPathComponent}
        }
        catch {
            return []
        }
    }

    #if os(macOS)
    func getImageInBundle(bundlePath: String) -> NSImage? {
        return NSImage.init(contentsOfFile: Bundle.main.bundleURL.appendingPathComponent(bundlePath).relativePath)
    }
    #elseif os(iOS)
    func getImageInBundle(bundlePath: String) -> UIImage? {
        return UIImage.init(contentsOfFile: Bundle.main.bundleURL.appendingPathComponent(bundlePath).relativePath)
    }
    #endif
}

extension String {
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func replace(index: Int, _ newChar: Character) -> String {
        var chars = Array(self)
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
}
