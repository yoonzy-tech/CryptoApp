//
//  CoinbaseService+Helpers.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/30.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import CryptoKit

extension CoinbaseService {
    func getTimestampSignature(requestPath: String,
                               method: String,
                               body: String) -> (String, String) {
        
        let date = Date().timeIntervalSince1970
        let cbAccessTimestamp = String(date)
        let secret = secret
        let requestPath = requestPath
        let body = body
        let method = method
        let message = "\(cbAccessTimestamp)\(method)\(requestPath)\(body)"
        
        guard let keyData = Data(base64Encoded: secret) else {
            fatalError("Failed to decode secret as base64")
        }
        
        let hmac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: SymmetricKey(data: keyData))
        
        let cbAccessSign = hmac.withUnsafeBytes { macBytes -> String in
            let data = Data(macBytes)
            return data.base64EncodedString()
        }
        return (cbAccessTimestamp, cbAccessSign)
    }
    
    func getApiResponse<T: Codable>(api: CoinbaseApi,
                                    authRequired: Bool,
                                    requestPath: String = "",
                                    httpMethod: HttpMethod = .GET,
                                    body: String = "",
                                    completion: @escaping (T) -> Void) {
        
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = URL(string: api.path) else {
            print("Invalid URL")
            return
        }
        
        print("URL: \(url)")
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authRequired {
            let timestampSignature = getTimestampSignature(requestPath: requestPath,
                                                           method: httpMethod.rawValue,
                                                           body: body)
            
            request.addValue(apiKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(passPhrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(timestampSignature.0, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(timestampSignature.1, forHTTPHeaderField: "cb-access-sign")
        }
        request.httpMethod = httpMethod.rawValue
        
        if httpMethod == .POST {
            let postData = body.data(using: .utf8)
            request.httpBody = postData
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                // print("Response: \(response)")
                completion(response)
            } catch {
                print("Error decoding data: \(error)")
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    func getApiResponseNoCompletion<T: Codable>(api: CoinbaseApi,
                                                authRequired: Bool,
                                                requestPath: String = "",
                                                httpMethod: HttpMethod = .GET,
                                                body: String = "") -> T? {
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: T?
        
        guard let url = URL(string: api.path) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authRequired {
            let timestampSignature = getTimestampSignature(requestPath: requestPath,
                                                           method: httpMethod.rawValue,
                                                           body: body)
            
            request.addValue(apiKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(passPhrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(timestampSignature.0, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(timestampSignature.1, forHTTPHeaderField: "cb-access-sign")
        }
        request.httpMethod = httpMethod.rawValue
        
        if httpMethod == .POST {
            let postData = body.data(using: .utf8)
            request.httpBody = postData
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                responseData = response
                print("📱 Response: \(responseData)")
            } catch {
                print("Error decoding data: \(error)")
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        return responseData
    }
}
