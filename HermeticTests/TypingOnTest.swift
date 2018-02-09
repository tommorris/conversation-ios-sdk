//
//  TypingOnTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class TypingOnTest: QuickSpec {
    
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
        
        context("send typing on") {
            it("should pass") {
                BasicOperations.login(with: self.client)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                let result = conversation.startTyping()
                
                expect(result) == true
            }
            
            it("should change member typing status") {
                BasicOperations.login(with: self.client)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.members.first?.typing.value).to(beFalse())
                    
                let result = conversation.startTyping()
                    
                expect(result) == true
                expect(conversation.members.first?.typing.value).toEventually(beTrue())
            }
            
            it("should not update member typing status for unknown conversation") {
                guard let token = ["template": "typing_on_specific",
                                   "cid": ["text:typing:on": "UNKNOWN-CID"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                let result = self.client.conversation.conversations.first?.startTyping()
                
                expect(result) == true
                expect(self.client.conversation.conversations.first?.members.first?.typing.value).toEventually(beFalse())
            }
            
            it("should not update member typing status for unknown member") {
                guard let token = ["template": "typing_on_specific",
                                   "from": ["text:typing:on": "UNKNOWN-MEM"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                let result = self.client.conversation.conversations.first?.startTyping()
                
                expect(result) == true
                expect(self.client.conversation.conversations.first?.members.first?.typing.value).toEventually(beFalse())
            }
            
            it("should not change conversations order for multiple conversations") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-multi-known-cid",
                                                "getinfo_setinfo_delete_conversation": "conversation-random-member",
                                                "send_getrange_events": "event-list-empty"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(2))
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                
                let conversation = self.client.conversation.conversations[1]
                guard let member = conversation.members.first else { return fail() }
                
                let result = conversation.startTyping()
                
                expect(result) == true
                expect(member.typing.value).toEventually(beTrue())
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
            }
        }
        
        context("receive typing on") {
            it("should pass for own member") {
                guard let token = ["template": ["session:success": "default,typing_on"],
                                   "from": ["session:success": TestConstants.Member.uuid],
                                   "wait": ["session:success": 3]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                guard let member = conversation.members.first else { return fail() }
                
                expect(member.typing.value).toEventually(beTrue())
            }
            
            it("should pass for another member") {
                guard let token = ["template": ["session:success": "default,typing_on"],
                                   "from": ["session:success": TestConstants.PeerMember.uuid],
                                   "wait": ["session:success": 3]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.first?.members[1].typing.value).toEventually(beTrue())
            }
            
            it("should not update member typing status for unknown conversation") {
                guard let token = ["template": ["session:success": "default,typing_on"],
                                   "cid": ["session:success": "UNKNOWN-CID"],
                                   "wait": ["session:success": 3]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.first?.members.first?.typing.value).toEventually(beFalse())
            }
            
            it("should not update member typing status for unknown member") {
                guard let token = ["template": ["session:success": "default,typing_on"],
                                   "from": ["session:success": "UNKNOWN-MEM"],
                                   "wait": ["session:success": 3]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.first?.members.first?.typing.value).toEventually(beFalse())
            }
            
            it("should not change conversations order for multiple conversations") {
                guard let token = ["template": ["session:success": "default,typing_on",
                                                "get_user_conversation_list": "conversation-list-multi-known-cid",
                                                "getinfo_setinfo_delete_conversation": ["conversation-single-member",
                                                                                        "conversation-random-members"],
                                                "send_getrange_events": "event-list-empty"],
                                                "from": ["session:success": TestConstants.Member.uuid],
                                                "wait": ["session:success": 3]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(2))
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                
                let conversation = self.client.conversation.conversations[1]
                guard let member = conversation.members.first else { return fail() }
                
                expect(member.typing.value).toEventually(beTrue())
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
            }
        }
    }
}
