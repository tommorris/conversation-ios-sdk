//
//  AuthenticationModel.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

internal struct AuthenticationModel: Decodable {
    
    // MARK:
    // MARK: Keys
    
    enum CodingKeys: String, CodingKey {
        case username
        case token
    }
    
    /// HTTP status code
    internal let username: String
    
    /// Auth token
    internal let token: String
    
    // MARK:
    // MARK: Initializers

    internal init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        username = try values.decode(String.self, forKey: .username)
        token = try values.decode(String.self, forKey: .token)
    }
}
