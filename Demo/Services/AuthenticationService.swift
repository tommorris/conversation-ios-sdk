//
//  AuthExample.swift
//  ConversationDemo
//
//  Created by James Green on 22/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Example of authenticating
internal struct AuthenticationService {
    
    // MARK:
    // MARK: Enum
    
    internal enum Result {
        case success(AuthenticationModel)
        case failure(Error)
    }
    
    // MARK:
    // MARK: Authentication
    
    /// validate user
    ///
    /// - Parameters:
    ///   - email: email
    ///   - result: response from auth server
    internal func validate(email: String, _ completion: @escaping (Result) -> Void) {
        SessionManager.default
            .request(AuthenticationRouter.authenticate(email: email))
            .validate()
            .responseData { response in
                guard let data = response.data,
                    let model = try? JSONDecoder().decode(AuthenticationModel.self, from: data) else {
                    return completion(.failure(NSError(domain: "", code: -1)))
                }
                
                completion(.success(model))
        }
    }
}
