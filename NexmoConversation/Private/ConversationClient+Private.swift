//
//  ConversationClient+Private.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 07/11/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// MARK: - Private methods that are not included in our framework, to be only used for testing
/// :nodoc:
public extension ConversationClient {
    
    // MARK:
    // MARK: Private - Testing: Token
    
    /// Check if token has been set for testingß
    public static var hasToken: Bool {
        return Keychain()[.token] != nil
    }
    
    /// Private - Set to use development mode endpoint
    /// :nodoc:
    public static func developmentMode(_ mode: Bool) {
        BaseURL.inDevelopmentMode = mode
    }
    
    /// Private - Add Authorization token for testing, not stored in keychain
    /// :nodoc:
    public func addAuthorization(with token: String) {
        networkController.token = token
    }
    
    // MARK:
    // MARK: Private - Testing Helper
    
    /// Private - Leave all conversations
    /// :nodoc:
    internal func leaveAllConversations() {
        conversation.conversations.refetch()

        conversation.conversations.forEach { $0.leave().subscribe().disposed(by: disposeBag) }
    }
}
