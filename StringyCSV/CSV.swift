//
//  CSV.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

struct CSV {
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

extension CSV: Serializable {
    
    init(name: String, path: String) throws {
        
    }
    
    func toString() -> [String] {
        let csvString = self.rows.reduce("") { (string, row) -> String in
            let rowString = row.reduce("") { (string, element) -> String in
                "\(string)\(string.length > 0 ? "," : "")\"\(element)\""
            }
            return "\(string)\(rowString)\n"
        }
        
        return [csvString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())]
    }
    
}
