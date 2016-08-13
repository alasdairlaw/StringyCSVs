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

enum Regex: String {
    case Comment = "\\/\\*.*\\*\\/"
    case Entry = "\".*\""
    case EntryElement = "\".*?\""
}

let path = Process.arguments[1]
let fileName = Process.arguments[2]

var strings = try Strings(name: fileName, path: path)

let csv = StringsToSCV.createCSV(stringsFile: strings)
let csvString = csv.toString().first!

let outputPath = "\(path)/\(fileName).csv"
try csvString.writeToFile(outputPath, atomically: false, encoding: NSUTF8StringEncoding)

let stringsStrings = strings.toString()

for (index, stringFile) in stringsStrings.enumerate() {
    let locale = strings.getLocales()[index]
    let stringsOutputPath = "\(path)/OutputStrings/\(locale.rawValue)\(fileName).strings"
    try stringFile.writeToFile(stringsOutputPath, atomically: false, encoding: NSUTF8StringEncoding)
}