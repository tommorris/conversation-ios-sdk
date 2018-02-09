//
//  InviteTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class InviteTest: QuickSpec, E2ECSClientSpec {    
    override func spec() {
        standardSetup()
        
        it("user can invite another user to a conversation they are a member of") {
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
            
            guard let firstConversation = self.client.conversation.conversations.first else { return fail() }
            
            var responseStatus = false
            _ = firstConversation.invite(Mock.peerUser.name).subscribe(onSuccess: {
                responseStatus = true
            }, onError: { error in
                fail()
            })
            
            expect(responseStatus).toEventually(beTrue())
            
            expect(firstConversation.state).toEventually(equal(MemberModel.State.joined))
            expect(firstConversation.members.count).toEventually(equal(2))
            expect(firstConversation.members[1].state).toEventually(equal(MemberModel.State.invited))
        }
    }
}
