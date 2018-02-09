//
//  JoinedTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class GetConversationTest: QuickSpec, E2ECSClientSpec {
    override func spec() {
        standardSetup()
        
        it("user can retrieve details of a conversation") {
            let conversationName = E2ETestCSClient.uniqueString
            var conversation: Conversation?
            do {
                conversation = try self.client.conversation.new(conversationName, withJoin: true).toBlocking().first()
            } catch let error {
                fail(error.localizedDescription)
            }
            
            expect(conversation).toEventuallyNot(beNil())
            expect(conversation?.name).toEventually(equal(conversationName))
            
            guard let conversationId = conversation?.uuid else { return fail() }
            var conversationResponse: Conversation?
            
            _ = self.client.conversation.conversation(with: conversationId).subscribe(onNext: { conversation in
                conversationResponse = conversation
            }, onError: { _ in
                fail()
            })
            
            expect(conversationResponse?.uuid).toEventually(equal(conversation?.uuid))
            expect(conversationResponse?.name).toEventually(equal(conversationName))
            expect(conversationResponse?.members.count).toEventually(equal(1))
            expect(conversationResponse?.members.first?.user.isMe).toEventually(beTrue())
            expect(conversationResponse?.state).toEventually(equal(.joined))
        }
    }
}
