//
//  CSV.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

struct CSV {
    var csv: CSwiftV?
    
    var rows = [[String]]()
    
    init(headers: [String]) {
        self.rows.append(headers)
    }
    
    mutating func addRow(row: [String]) {
        self.rows.append(row)
    }
    
    mutating func addRows(rows: [[String]]) {
        self.rows.appendContentsOf(rows)
    }
}

extension CSV: Localizable {
    func getLocales() -> [Locale] {
        guard let headers = csv?.headers ?? self.rows.first else {
            return []
        }
        
        var locales = [Locale]()
        
        for header in headers {
            if let locale = Locale(rawValue: header) {
                locales.append(locale)
            }
        }
        
        return locales
    }
}

extension CSV: Serializable {
    init(name: String, path: String) throws {
        let filePath = "\(path)/\(name).csv"
        let csvFile = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        self.csv = CSwiftV(with: csvFile)
        self.rows.append(self.csv!.headers ?? [])
        self.rows.appendContentsOf(self.csv!.rows)
    }
    
    func toString() -> [String] {
        let csvString = self.rows.reduce("") { (string, row) -> String in
            let rowString = row.reduce("") { (string, element) -> String in
                "\(string)\(string.length > 0 ? "," : "")\"\(element)\""
            }
            return "\(string)\(rowString)\r\n"
        }
        
        return [csvString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())]
    }
    
}
