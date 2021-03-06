//
//  ApiService.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Fedir Nepyyvoda on 2016-09-27.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the Rogue iOS app.
//
//  The Rogue iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Rogue iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the Rogue iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

class ApiService {
    
    static let shared = ApiService()
    
    static var authParams: [URLQueryItem] {
        guard let sessionToken = KeyChain.sessionToken else {
            return []
        }
        
        
        return [URLQueryItem(name: "session_token", value: sessionToken)]
    }
    
    private func getAccessToken(completion: @escaping (String) -> Void) {
        Application.shared.authentication.getAccessToken(completion: { accessKey in
            completion(accessKey)
        });
    }
    
    func isSuccessCode(statusCode: Int = 500) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    func request<T>(_ requestDI: ApiRequestDI, completion: @escaping (Result<T>) -> Void) {
        let requestName = "\(requestDI.method.description) \(requestDI.endpoint)"
        let request = APIRequest(method: requestDI.method, path: requestDI.endpoint, contentType: requestDI.contentType)
        
        if let params = requestDI.params {
            request.queryItems = params
        }
        
        log(info: "\(requestName) started")
        
        getAccessToken { (accessToken) in
            
            request.headers = [HTTPHeader(field: "Authorization", value: "\(accessToken)")]
            
            APIClient().perform(request) { result in
                // TODO: antonio - perhaps no need to call in the main thread since no ui code is running anymore..
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(let response):
                                                
                        if let data = response.body {
                            let decoder = JSONDecoder()
                            
                             decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            do {
                                let successResponse = try decoder.decode(T.self, from: data)
                                log(info: "\(requestName) success")
                                completion(.success(successResponse))
                                return
                            } catch { }
                            
                            do {
                                let errorResponse = try decoder.decode(ApiError.self, from: data)
                                let error = self.getServiceError(message: errorResponse.error, code: response.statusCode)
                                log(info: "\(requestName) error response")
                                completion(.failure(error))
                                return
                            } catch { }
                        }
                        
                        log(info: "\(requestName) parse error")
                        completion(.failure(nil))
                        
                    case .failure:
                        log(info: "\(requestName) failure")
                        completion(.failure(nil))
                    }
                }
            }
        }
    }
    
    func requestCustomError<T, E>(_ requestDI: ApiRequestDI, completion: @escaping (ResultCustomError<T, E>) -> Void) {
        let requestName = "\(requestDI.method.description) \(requestDI.endpoint)"
        let request = APIRequest(method: requestDI.method, path: requestDI.endpoint, contentType: requestDI.contentType)
        
        if let params = requestDI.params {
            request.queryItems = params
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        log(info: "\(requestName) started")
        
        APIClient().perform(request) { result in
            
            print("antonio.. making request")
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                switch result {
                case .success(let response):
                    if let data = response.body {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        do {
                            let successResponse = try decoder.decode(T.self, from: data)
                            completion(.success(successResponse))
                            log(info: "\(requestName) success")
                            //response from api Account(accountId: "i-ULLY-B97B-EZ5A")
                            log(info: "response from api \(successResponse)")
                            return
                        } catch {}
                        
                        do {
                            let errorResponse = try decoder.decode(E.self, from: data)
                            completion(.failure(errorResponse))
                            log(info: "\(requestName) error response")
                            return
                        } catch {}
                    }
                    
                    completion(.failure(nil))
                    log(info: "\(requestName) parse error")
                case .failure:
                    log(info: "\(requestName) failure")
                    completion(.failure(nil))
                }
            }
        }
    }
    
    // MARK: - Helper methods -
    
    func getServiceError(message: String, code: Int = 99) -> NSError {
        return NSError(
            domain: "ApiServiceDomain",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
    
}
