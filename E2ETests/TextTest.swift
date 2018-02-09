//
//  MessageTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class TextTest: QuickSpec, E2ECSConversationSpec {
    var conversation: Conversation?    
    var conversationName: String = ""
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        standardSetup()
        
        it("user can send text message to a conversation they are a member of") {
            guard let conversation = self.client.conversation.conversations.first else { return fail() }
            guard let _ = try? conversation.send(TestConstants.Text.text) else { return fail() }
            expect(conversation.events.count).toEventually(equal(2))
            expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
            expect((conversation.events.last as? TextEvent)?.text).toEventually(equal(TestConstants.Text.text))
        }
    }
}
