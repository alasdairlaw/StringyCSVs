//
//  StringsToCSV.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

struct StringsToSCV {
    
    static func createCSV(stringsFile strings: Strings) -> CSV {
        let localeStrings = strings.getLocales().map { $0.rawValue }
        var csv = CSV(headers: ["Key"] + localeStrings + ["Comment"])
        
        let rows = strings.entries.map { (entry) -> [String] in
            var values = [String]()
            for locale in strings.getLocales() {
                let value = entry.1.values[locale]
                values.append(value ?? "")
            }
            return [entry.0] + values + [entry.1.comment]
        }
        
        let sortedRows = rows.sort { (rowA, rowB) -> Bool in
            rowA.first!.lowercaseString < rowB.first!.lowercaseString
        }
        
        csv.addRows(sortedRows)
        
        return csv
    }
    
}
