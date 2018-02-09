//
//  GetCurrentUserConversationsTest.swift
//  NexmoConversationE2ETests
//
//  Created by Ivan on 06/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class GetCurrentApplicationConversationsTest: QuickSpec, E2ECSClientSpec {
    override func spec() {
        super.spec()
        Nimble.AsyncDefaults.Timeout = 15
        
        it("user can get current application conversations") {
            var retrievedConversation = false
            var expected = false
            
            _ = self.client.conversation.new(E2ETestCSClient.uniqueString, withJoin: false).subscribe(onNext: { _ in
                retrievedConversation = true
            }, onCompleted: {
                expected = true
            })
            
            expect(expected).toEventually(beTrue())
            expect(retrievedConversation).toEventuallyNot(beTrue())
            
            var conversationResponse: [ConversationController.LiteConversation]?
            
            _ = self.client.conversation.all().subscribe(onNext: { conversation in
                conversationResponse = conversation
            }, onError: { _ in
                fail()
            })
            
            expect(conversationResponse).toEventuallyNot(beNil())
            expect(conversationResponse?.count).toEventuallyNot(equal(0))
        }
    }
}
