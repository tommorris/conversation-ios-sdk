//
//  DatabaseFactory.swift
//  NexmoConversation
//
//  Created by shams ahmed on 05/07/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
@testable import NexmoConversation

@objc
@objcMembers
public class DatabaseFactory: NSObject {
    
    // MARK:
    // MARK: Clear
    
    static func clear(_ client: ConversationClient) {
        _ = try? client.storage.databaseManager.clear()
    }
    
    // MARK:
    // MARK: Conversation

    static func saveConversation(with client: ConversationClient) {
        let mock = SimpleMockDatabase()
        
        _ = try? client.storage.databaseManager.member.insert(mock.DBMember1)
        _ = try? client.storage.databaseManager.member.insert(mock.DBMember2)
        _ = try? client.syncManager.save(mock.conversation1.rest)
    }
}
