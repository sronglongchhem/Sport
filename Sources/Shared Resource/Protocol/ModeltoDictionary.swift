//
//  ModeltoDictionary.swift
//  SharedResources
//
//  Created by 100456065 on 19/03/2019.
//  Copyright © 2019 100456065. All rights reserved.
//

import Foundation

protocol ModeltoDictionaryProtocol {
    var asDictionary : [String:Any] {get}
}

extension ModeltoDictionaryProtocol {
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?,value:Any) -> (String,Any)? in
            guard label != nil else { return nil }
            return (label!,value)
        }).compactMap{ $0 })
        return dict
    }
}
