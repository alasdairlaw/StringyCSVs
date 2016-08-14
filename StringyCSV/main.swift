//
//  main.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

// For each base strings file
    // For each localised file
        // Add column for localization
        // For each base key
            // If we can find a localised value
            // Add localized value to base key's values
    // Output CSV of all known values

// Import CSV file
// For each language on CSV
    // Grab localized strings file
    // For each key in CSV
        // Update localised strings file with the CSV value
    // Save localized strings file back


import Foundation

protocol Serializable {
    init(name: String, path: String) throws
    func toString() -> [String]
}

enum Locale: String {
    case English = "English"
    case German = "German"
    
    func folderName() -> String {
        switch self {
        case .English:
            return "en.lproj"
        case .German:
            return "de.lproj"
        }
    }
    
    static func allLocales() -> [Locale] {
        return [.English, .German]
    }
    
    static func baseLocale() -> Locale {
        return Locale.English
    }
}

enum Regex: String {
    case Comment = "\\/\\*.*\\*\\/"
    case Entry = "\".*\""
    case EntryElement = "\".*?[^\\\\]\""
}

protocol Localizable {
    func getLocales() -> [Locale]
}

func createCSV() throws {
    let path = Process.arguments[1]
    let csvPath = Process.arguments[2]
    
    var files = [NSURL]()
    
    for locale in Locale.allLocales() {
        let localePath = "\(path)/\(locale.folderName())"
        let localeFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(localePath).map { (file) -> NSURL in
            NSURL(fileURLWithPath: "\(path)/\(file)")
            }.filter({ (url) -> Bool in
                url.pathExtension == "strings"
            })
        files.appendContentsOf(localeFiles)
    }
    
    let csvFolderURL = NSURL(fileURLWithPath: "\(csvPath)/CSVs")
    try NSFileManager.defaultManager().createDirectoryAtURL(csvFolderURL, withIntermediateDirectories: true, attributes: nil)
    
    for file in files {
        guard let fileName = file.lastPathComponent?.stringByDeletingPathExtension() else {
            continue
        }
        let strings = try Strings(name: fileName, path: path)
        
        let csv = StringsToSCV.createCSV(stringsFile: strings)
        let csvString = csv.toString().first!
        
        let outputPath = "\(csvFolderURL.path!)/\(fileName).csv"
        try csvString.writeToFile(outputPath, atomically: false, encoding: NSUTF8StringEncoding)
    }
}

func CSVImport() throws {
    let path = Process.arguments[1]
    let csvPath = "\(Process.arguments[2])/CSVs"
    
    var files = [NSURL]()
    
    for locale in Locale.allLocales() {
        let localePath = "\(path)/\(locale.folderName())"
        let localeFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(localePath).map { (file) -> NSURL in
            NSURL(fileURLWithPath: "\(path)/\(file)")
            }.filter({ (url) -> Bool in
                url.pathExtension == "strings"
            })
        files.appendContentsOf(localeFiles)
    }
    
    for file in files {
        guard let fileName = file.lastPathComponent?.stringByDeletingPathExtension() else {
            continue
        }
        let csv = try CSV(name: fileName, path: csvPath)
        var strings = try Strings(name: fileName, path: path)
        
        for row in csv.csv!.keyedRows! {
            for locale in Locale.allLocales() {
                guard let localeValue = row[locale.rawValue] else {
                    continue
                }
                guard let key = row["Key"] else {
                    continue
                }
                guard let comment = row["Comment"] else {
                    continue
                }
                
                strings.addEntry((key: key, value: localeValue, comment: comment), locale: locale)
            }
        }
        
        let stringsStrings = strings.toString()
        
        for (index, stringFile) in stringsStrings.enumerate() {
            let locale = strings.getLocales()[index]
            
            let stringsOutputURL = NSURL(fileURLWithPath: "\(path)/\(locale.folderName())", isDirectory: true)
            let stringsOutputFileURL = stringsOutputURL.URLByAppendingPathComponent("/\(fileName).strings")
            try NSFileManager.defaultManager().createDirectoryAtURL(stringsOutputURL, withIntermediateDirectories: true, attributes: nil)
            try stringFile.writeToFile(stringsOutputFileURL.path!, atomically: false, encoding: NSUTF8StringEncoding)
        }
    }
}

func updateStrings() throws {
    let path = Process.arguments[1]
    
    var files = [NSURL]()
    
    for locale in Locale.allLocales() {
        let localePath = "\(path)/\(locale.folderName())"
        let localeFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(localePath).map { (file) -> NSURL in
            NSURL(fileURLWithPath: "\(path)/\(file)")
            }.filter({ (url) -> Bool in
                url.pathExtension == "strings"
        })
        files.appendContentsOf(localeFiles)
    }
    
    for file in files {
        guard let fileName = file.lastPathComponent?.stringByDeletingPathExtension() else {
            continue
        }
        let strings = try Strings(name: fileName, path: path)
        
        let stringsStrings = strings.toString()
        
        for (index, stringFile) in stringsStrings.enumerate() {
            let locale = strings.getLocales()[index]
            
            let stringsOutputURL = NSURL(fileURLWithPath: "\(path)/\(locale.folderName())", isDirectory: true)
            let stringsOutputFileURL = stringsOutputURL.URLByAppendingPathComponent("/\(fileName).strings")
            try NSFileManager.defaultManager().createDirectoryAtURL(stringsOutputURL, withIntermediateDirectories: true, attributes: nil)
            try stringFile.writeToFile(stringsOutputFileURL.path!, atomically: false, encoding: NSUTF8StringEncoding)
        }
    }
}


//try createCSV()
try CSVImport()
//try updateStrings()

