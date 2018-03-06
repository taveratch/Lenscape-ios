//
//  Dictionary.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating public func setValue(value: Any, forKeyPath keyPath: String) {
        var keys = keyPath.components(separatedBy: ".")
        guard let first = keys.first as? Key else { print("Unable to use string as key on type: \(Key.self)"); return }
        keys.remove(at: 0)
        if keys.isEmpty, let settable = value as? Value {
            self[first] = settable
        } else {
            let rejoined = keys.joined(separator: ".")
            var subdict: [NSObject : AnyObject] = [:]
            if let sub = self[first] as? [NSObject : AnyObject] {
                subdict = sub
            }
            subdict.setValue(value: value, forKeyPath: rejoined)
            if let settable = subdict as? Value {
                self[first] = settable
            } else {
                print("Unable to set value: \(subdict) to dictionary of type: \(type(of: self))")
            }
        }
        
    }
    
    public func valueForKeyPath<T>(keyPath: String) -> T? {
        var keys = keyPath.components(separatedBy: ".")
        guard let first = keys.first as? Key else { print("Unable to use string as key on type: \(Key.self)"); return nil }
        guard let value = self[first] else { return nil }
        keys.remove(at: 0)
        if !keys.isEmpty, let subDict = value as? [NSObject : AnyObject] {
            let rejoined = keys.joined(separator: ".")
            
            return subDict.valueForKeyPath(keyPath: rejoined)
        }
        return value as? T
    }
}
