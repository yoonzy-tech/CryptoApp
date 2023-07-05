//
//  CoinbaseService.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import Foundation

final class CoinbaseService {
    
    static let shared = CoinbaseService()
    
    private init() {}
    
}

extension CoinbaseService {
    
    func fetchAccounts(completion: @escaping ([Account]) -> Void) {
        getApiResponse(api: .accounts,
                       authRequired: true, requestPath: "/accounts", httpMethod: .GET) { (accounts: [Account]) in
            completion(accounts)
        }
    }
    
    func fetchTradingPairs(completion: @escaping ([TradingPair]) -> Void) {
        getApiResponse(api: .allTradingPairs,
                       authRequired: false) { (tradingPairs: [TradingPair]) in
            completion(tradingPairs)
        }
    }
    
    func fetchUserProfile(completion: @escaping (Profile) -> Void) {
        getApiResponse(api: .profile,
                       authRequired: true, requestPath: "/profiles?active", httpMethod: .GET) { (profiles: [Profile]) in
            guard let profile = profiles.first else { return }
            completion(profile)
        }
    }
    
    func fetchProductStats(productID: String,
                           completion: @escaping (ProductStats) -> Void) {
        getApiResponse(api: .productStats(productID: productID),
                       authRequired: false) { (productStats: ProductStats) in
            completion(productStats)
        }
    }
    
    func fetchCurrencyDetail(currencyID: String, completion: @escaping (CurrencyInfo) -> Void) {
        getApiResponse(api: .currencyDetail(currencyID: currencyID),
                       authRequired: false) { (currencyInfo: CurrencyInfo) in
            completion(currencyInfo)
        }
    }
    
    func fetchProductOrders(productID: String, status: String = "done", limit: Int = 5, completion: @escaping ([Order]) -> Void) {
        // Only showing top 5-6 history, newest on top
        getApiResponse(api: .allOrders(limit: limit,
                                       status: status,
                                       productID: productID),
                       authRequired: true,
                       requestPath: "/orders?limit=\(limit)&status=\(status)&product_id=\(productID)",
                       httpMethod: .GET) { (orders: [Order]) in
            completion(orders)
        }
    }
    
    func fetchCurrencyRate(currency: String = "USD", completion: @escaping (Double) -> Void) {
        getApiResponse(api: .exchangeRate(currency: currency), authRequired: false) { (allRates: ExchangeRates) in
            let rate = Double(allRates.data.rates["TWD"] ?? "0") ?? 0
            completion(rate)
        }
    }
    
    func fetchProductCandles(productID: String,
                             granularity: String = "",
                             startTime: String = "",
                             endTime: String = "",
                             completion: @escaping ([[Double]]) -> Void) {
        
        getApiResponse(api: .allCandles(productID: productID,
                                        granularity: granularity,
                                        start: startTime,
                                        end: endTime),
                       authRequired: false) { (candles: [[Double]]) in
            completion(candles)
        }
    }
    
    func getExchangeRate(from base: String = "USD", to currency: String = "TWD") -> Double? {
        
        guard let response: ExchangeRates? = getApiResponseNoCompletion(api: .exchangeRate(currency: base),
                                                                        authRequired: false) else {
            print("Failed to fetch current \(currency) exchange rate ")
            return nil
        }
        
        guard let rateToTWD = response?.data.rates[currency] else {
            print("Unable to get the exchange rate to \(currency)")
            return nil
        }
        
        return Double(rateToTWD) ?? 0
    }
    
    func fetchAccountsNew() -> [Account]? {
        guard let accounts: [Account]? = getApiResponseNoCompletion(api: .accounts,
                                                                    authRequired: true,
                                                                    requestPath: "/accounts", httpMethod: .GET) else {
            print("Failed to fetch accounts.")
            return nil
        }
        return accounts
    }
}
