//
//  Strings.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

struct Strings {
    var entries = [String: (values: [Locale: String], comment: String)]()
    private var locales = [Locale]()
    
    mutating func addEntry(entry: (key: String, value: String, comment: String), locale: Locale) {
        if self.entries[entry.key] != nil {
            self.entries[entry.key]!.values[locale] = entry.value
        } else if locale == Locale.baseLocale() {
            self.entries[entry.key] = (values: [locale: entry.value], comment: entry.comment)
        }
    }
}

extension Strings: Localizable {
    
    func getLocales() -> [Locale] {
        return self.locales.sort({ (localeA, localeB) -> Bool in
            return localeA.rawValue < localeB.rawValue
        })
    }
    
}

extension Strings: Serializable {
    
    init(name: String, path: String) throws {
        let locales = Locale.allLocales()
        
        for locale in locales {
            self.locales.append(locale)
            let localePath = "\(path)/\(locale.folderName())/\(name).strings"
            
            do {
                let stringsFile = try String(contentsOfFile: localePath, encoding: NSUTF8StringEncoding)
                let values = stringsFile.componentsSeparatedByString(";\n")
                
                for value in values {
                    guard let comment = value.matchesForRegex(.Comment).last else {
                        continue
                    }
                    guard let entry = value.matchesForRegex(.Entry).last else {
                        continue
                    }
                    
                    guard let entryKey = entry.matchesForRegex(.EntryElement).first else {
                        continue
                    }
                    
                    guard let entryValue = entry.matchesForRegex(.EntryElement).last else {
                        continue
                    }
                    
                    let trimmedKey = entryKey.substringWithRange(entryKey.startIndex.successor() ..< entryKey.endIndex.predecessor())
                    let trimmedValue = entryValue.substringWithRange(entryValue.startIndex.successor() ..< entryValue.endIndex.predecessor())
                    let trimmedComment = comment.subString(3, length: comment.length - 3 - 3)
                    
                    if self.entries[trimmedKey] != nil {
                        self.entries[trimmedKey]!.values[locale] = trimmedValue
                    } else if locale == Locale.baseLocale() {
                        self.entries[trimmedKey] = (values: [locale: trimmedValue], comment: trimmedComment)
                    }
                }
            }
            catch {
                
            }
        }
    }
    
    func toString() -> [String] {
        var fileStrings = [String]()
        
        for locale in self.getLocales() {
            var fileString = "\n"
            let entryKeys = self.entries.keys.sort({ (keyA, keyB) -> Bool in
                return keyA.lowercaseString < keyB.lowercaseString
            })
            for (index, entryKey) in entryKeys.enumerate() {
                let entry = self.entries[entryKey]!
                
                if let entryValue = entry.values[locale] {
                    let commentString = "/* \(entry.comment) */"
                    let entryString = "\"\(entryKey)\" = \"\(entryValue)\";"
                    
                    var string = "\(commentString)\n\(entryString)\n"
                    
                    if index < entryKeys.count - 1 {
                        string += "\n"
                    }
                    
                    fileString += string
                }
            }
            fileStrings.append(fileString)
        }
        
        return fileStrings
    }
    
}
