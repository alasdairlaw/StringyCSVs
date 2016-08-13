//
//  String+Strings.swift
//  StringyCSV
//
//  Created by Alasdair Law on 12/08/2016.
//  Copyright © 2016 Alasdair Law. All rights reserved.
//

import Foundation

extension String {
    func isCommentLine() -> Bool {
        let firstIndex = self.indexOf("/*")
        let lastIndex = self.lastIndexOf("*/")
        
        guard firstIndex > 0 && lastIndex > 0 else {
            return false
        }
        
        return firstIndex == 0 && lastIndex == self.length
    }
    
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character {
        get {
            let index = self.characters.startIndex.advancedBy(i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.startIndex.advancedBy(r.startIndex)
            let endIndex = self.characters.startIndex.advancedBy(r.endIndex - 1)
            
            return self[startIndex..<endIndex]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String {
        let start = self.characters.startIndex.advancedBy(startIndex)
        let end = self.characters.startIndex.advancedBy(startIndex + length)
        return self.substringWithRange(start ..< end)
    }
    
    func indexOf(target: String) -> Int {
        let range = self.rangeOfString(target)
        if let range = range {
            return self.characters.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int {
        let startRange = self.characters.startIndex.advancedBy(startIndex)
        
        let range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: startRange ..< self.endIndex)
        
        if let range = range {
            return self.characters.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func matchesForRegex(regex: Regex) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue, options: [])
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
