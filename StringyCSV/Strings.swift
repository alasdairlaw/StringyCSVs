//
//  Strings.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

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
}

struct Strings {
    var entries = [String: (values: [Locale: String], comment: String)]()
    private var locales = [Locale]()
    
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
                let values = stringsFile.componentsSeparatedByCharactersInSet(NSCharacterSet.init(charactersInString: ";"))
                
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
                    
                    let trimmedKey = entryKey.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "\" ")).stringByReplacingOccurrencesOfString("\"", withString: "\"\"")
                    let trimmedValue = entryValue.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "\" ")).stringByReplacingOccurrencesOfString("\"", withString: "\"\"")
                    let trimmedComment = comment.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "\\/\\*\\ ")).stringByReplacingOccurrencesOfString("\"", withString: "\"\"")
                    
                    if self.entries[trimmedKey] != nil {
                        self.entries[trimmedKey]!.values[locale] = trimmedValue
                    } else {
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
            var fileString = ""
            let entryKeys = self.entries.keys.sort({ (keyA, keyB) -> Bool in
                return keyA < keyB
            })
            for entryKey in entryKeys {
                let entry = self.entries[entryKey]!
                guard let entryValue = entry.values[locale] else {
                    continue
                }
                let commentString = "/* \(entry.comment) */"
                let entryString = "\"\(entryKey)\" = \"\(entryValue)\";"
                
                let string = "\(commentString)\n\(entryString)\n\n"
                
                fileString += string
            }
            fileStrings.append(fileString)
        }
        
        return fileStrings
    }
}
