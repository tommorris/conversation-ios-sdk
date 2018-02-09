//
//  File.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Router for auth example
internal enum AuthenticationRouter: URLRequestConvertible {
    
    /// Authenticate
    case authenticate(email: String)
    
    // MARK:
    // MARK: Request
    
    private var method: HTTPMethod {
        switch self {
        case .authenticate: return .get
        }
    }
    
    private var path: String {
        switch self {
        case .authenticate: return Constants.URL.acme
        }
    }
    
    // MARK:
    // MARK: URLRequestConvertible
    
    /// Build request
    internal func asURLRequest() throws -> URLRequest {
        switch self {
        case .authenticate(let email):
            let url = try path.asURL().appendingPathComponent(email)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue

            return urlRequest
        }
    }
}
