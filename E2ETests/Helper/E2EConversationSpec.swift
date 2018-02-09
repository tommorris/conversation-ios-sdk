//
//  ConversationClientSpec.swift
//  NexmoConversation
//
//  Created by Ashley Arthur on 27/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble
import NexmoConversation

// MARK: StandardSpec

// StandardSpec aims to share standard setup code between QuickSpecs
protocol StandardizeSpec: class {
    func standardSetup()
}

extension StandardizeSpec {
    func standardSetup() {
    }
}

// MARK: E2ECSClientSpec

protocol E2ECSClientSpec: StandardizeSpec {
    var client: ConversationClient { get }
}

extension E2ECSClientSpec {
    var client: ConversationClient {
        return ConversationClient.instance
    }
}

// MARK: E2ECSConversationSpec

protocol E2ECSConversationSpec: E2ECSClientSpec {
    var conversationName: String { get set }
    var conversation: Conversation? { get set }
}

extension E2ECSConversationSpec where Self: QuickSpec {
    func standardSetup() {
        continueAfterFailure = false
        
        beforeEach {
            // Setup a conversation for each test 
            self.conversationName = E2ETestCSClient.uniqueString
            do {
                self.conversation = try self.client.conversation.new(self.conversationName, withJoin: true).toBlocking().first()
            } catch let error {
                fail(error.localizedDescription)
            }
        }
    }
}
