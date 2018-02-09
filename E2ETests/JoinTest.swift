//
//  JoinTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class JoinTest: QuickSpec, E2ECSClientSpec {
    override func spec() {
        standardSetup()
        
        it("user can join a conversation they have created") {
            
            let conversationName = E2ETestCSClient.uniqueString
            var retrievedConversation = false
            var expected = false
            
            // create new conversation without joining it
            _ = self.client.conversation.new(conversationName, withJoin: false).subscribe(onNext: { _ in
                retrievedConversation = true
            }, onCompleted: {
                expected = true
            })
            
            expect(expected).toEventually(beTrue())
            expect(retrievedConversation).toEventuallyNot(beTrue())
            expect(self.client.conversation.conversations.count).toEventually(equal(0))
            
            var conversationResponse: [ConversationController.LiteConversation]?
            
            // get all conversations for current application and filter out the new conversation
            _ = self.client.conversation.all().subscribe(onNext: { conversation in
                conversationResponse = conversation
            }, onError: { _ in
                fail()
            })
            
            expect(conversationResponse).toEventuallyNot(beNil())
            expect(conversationResponse?.count).toEventuallyNot(equal(0))
            
            guard let conversationPreview = conversationResponse?.first(where: { $0.name == conversationName }) else { return fail() }
            
            var conversation: Conversation?
            
            _ = self.client.conversation.conversation(with: conversationPreview.uuid).subscribe(onNext: { response in
                conversation = response
            }, onError: { _ in
                fail()
            })
            
            var responseStatus = false
            
            _ = conversation?.join().subscribe(onSuccess: {
                responseStatus = true
            })
            
            expect(responseStatus).toEventually(beTrue())
            expect(conversation?.state).toEventually(equal(MemberModel.State.joined))
        }
    }
}
