//
//  ConversationTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class CreateConversationTest: QuickSpec, E2ECSClientSpec  {
    override func spec() {
        standardSetup()
        
        it("user can create conversation without joining it") {
            let conversationName = E2ETestCSClient.uniqueString
            var retrievedConversation = false
            var expected = false
            
            _ = self.client.conversation.new(conversationName, withJoin: false).subscribe(onNext: { _ in
                retrievedConversation = true
            }, onCompleted: {
                expected = true
            })
            
            expect(expected).toEventually(beTrue())
            expect(retrievedConversation).toEventuallyNot(beTrue())
            expect(self.client.conversation.conversations.count).toEventually(equal(0))
        }
        
        it("user can create conversation and automatically join it") {
            let conversationName = E2ETestCSClient.uniqueString
            var conversation: Conversation?
            do {
                conversation = try self.client.conversation.new(conversationName, withJoin: true).toBlocking().first()
            } catch let error {
                fail(error.localizedDescription)
            }
            
            expect(conversation).toEventuallyNot(beNil())
            expect(conversation?.name).toEventually(equal(conversationName))
            expect(conversation?.members.count).toEventually(equal(1))
            expect(conversation?.members.first?.user.isMe).toEventually(beTrue())
            expect(self.client.conversation.conversations.count).toEventually(equal(1))
        }
    }
}
