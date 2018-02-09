//
//  GetConversationEventsTest.swift
//  NexmoConversation
//
//  Created by Ivan on 20/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class GetConversationEventsTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    let client = ConversationClient.instance
    
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 5
        Nimble.AsyncDefaults.PollInterval = 1
        
        beforeEach {

        }
        
        afterEach {
            BasicOperations.logout(client: self.client)
        }
        
        context("get conversation events") {
            it("should pass for multiple events") {
                BasicOperations.login(with: self.client)
                
                let events = self.client.conversation.conversations.first?.events
                expect(events?.count).toEventuallyNot(equal(0))
            }
            
            it("should pass for single event") {
                BasicOperations.login(with: self.client)
                
                let conversation = self.client.conversation.conversations.first
                let event = conversation?.events.last
                
                expect(event).toEventuallyNot(beNil())
            }
            
            it("should pass for newly joined conversation") {
                guard let token = ["template": ["session:success": "default,invited",
                                                "get_user_conversation_list": "conversation-list-empty"],
                                   "state": ["getinfo_setinfo_delete_conversation":
                                                [MemberModel.State.invited.rawValue.uppercased(),
                                                 MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": TestConstants.User.uuid,
                                   "peer_member_id": TestConstants.Member.uuid,
                                   "peer_user_name": TestConstants.User.name,
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var conversationInvited: Conversation?
                var responseStatus: Bool?
                
                _ = self.client.conversation.conversations.asObservable.subscribe(onNext: { change in
                    switch change {
                    case .inserted(let conversation, _): conversationInvited = conversation
                    default: break
                    }
                })
                
                expect(conversationInvited).toEventuallyNot(beNil())

                _ = conversationInvited?.join().subscribe(onSuccess: {
                    responseStatus = true
                })
                
                expect(responseStatus).toEventually(beTrue())
                
                let joinedConversation = self.client.conversation.conversations.first
                expect(joinedConversation?.state).toEventually(equal(MemberModel.State.joined))
                expect(joinedConversation?.events.count).toEventuallyNot(equal(0))
            }
        }
    }
}
