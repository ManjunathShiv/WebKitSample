//
//  Country.swift
//  WebKitSample
//
//  Created by Manjunath Shivakumara on 26/02/18.
//  Copyright © 2018 Manjunath Shivakumara. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol CountryJSExp : JSExport {
    var countryName: String { get set }
    var countryGdp: String { get set }
    
    func getCountryDetails() -> String
    
    /// create and return a new Person instance with `countryName` and `countryGdp`
    static func createWithCountryData(countryName: String, countryGdp: String) -> Country
}

// Custom class must inherit from `NSObject`
@objc class Country : NSObject, CountryJSExp {
    
    
    // properties must be declared as `dynamic`
    dynamic var countryName: String
    dynamic var countryGdp: String
    
    init(cname: String, cgdp: String) {
        self.countryName = cname
        self.countryGdp = cgdp
    }
    
    func getCountryDetails() -> String {
        return "\(countryName) \(countryGdp)"
    }
    
    static func createWithCountryData(countryName: String, countryGdp: String) -> Country {
        return Country(cname:countryName, cgdp:countryGdp)
    }

}
