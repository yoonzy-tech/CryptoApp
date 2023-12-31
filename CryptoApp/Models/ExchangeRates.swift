//
//  Price.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import Foundation

struct ExchangeRates: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let currency: String
    let rates: [String: String]
}
