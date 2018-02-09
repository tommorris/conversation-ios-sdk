//
//  CreateConversationTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import NexmoConversation
import RxSwift
import RxTest
import RxBlocking

class CreateConversationTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    let client = ConversationClient.instance
    let conversationName = "CON-new-test"
    
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 5
        Nimble.AsyncDefaults.PollInterval = 1
        
        beforeEach {
            
        }
        
        afterEach {
            BasicOperations.logout(client: self.client)
        }
        
        context("create joined conversation") {
            it("should pass with returned conversation object") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-empty",
                                                "getinfo_setinfo_delete_conversation": "conversation-single-member",
                                                "send_getrange_events": "event-list-empty"],
                                   "cname": self.conversationName].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var conversation: Conversation?

                do {
                    conversation = try self.client.conversation.new(self.conversationName, withJoin: true).toBlocking().first()
                } catch let error {
                    fail(error.localizedDescription)
                }

                expect(conversation?.uuid.isEmpty).toEventually(beFalse())
                expect(conversation?.name).toEventually(equal(self.conversationName))
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                expect(self.client.conversation.conversations[0].members.isEmpty).toEventuallyNot(beTrue())
                expect(self.client.conversation.conversations[0].members.count).toEventually(equal(1))
            }
            
            it("should fail when user is not logged in") {
                self.client.addAuthorization(with: "")
                
                let newConversation = try? self.client.conversation.new(self.conversationName, withJoin: true).toBlocking().first()
                
                expect(self.client.account.state.value) == AccountController.State.loggedOut
                expect(newConversation).to(beNil())
            }
            
            it("should fail when malformed JSON is returned by server") {
                let token = TokenBuilder(response: .createGetInfoConversations).post.build
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseError: Error?
                
                _ = self.client.conversation.new(self.conversationName, withJoin: true).subscribe(onError: { error in
                    responseError = error
                })
                
                expect(responseError).toEventuallyNot(beNil())
            }
        }
        
        context("create non-joined conversation") {
            it("should complete with no conversation object") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-empty",
                                                "getinfo_setinfo_delete_conversation": "conversation-single-member",
                                                "send_getrange_events": "event-list-empty"],
                                   "cname": self.conversationName].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var receivedConversation = false
                var expected = false
                
                _ = self.client.conversation.new(self.conversationName, withJoin: false).subscribe(onNext: { _ in
                    receivedConversation = true
                }, onCompleted: {
                    expected = true
                })
                
                expect(expected).toEventually(beTrue())
                expect(receivedConversation).toEventuallyNot(beTrue())
                expect(self.client.conversation.conversations.count).toEventuallyNot(equal(1))
                expect(self.client.conversation.conversations.isEmpty).toEventually(beTrue())
            }
            
            it("should fail when user is not logged in") {
                self.client.addAuthorization(with: "")
                
                let newConversation = try? self.client.conversation.new(self.conversationName, withJoin: false).toBlocking().first()
                
                expect(self.client.account.state.value) == AccountController.State.loggedOut
                expect(newConversation).to(beNil())
            }
            
            it("should fail when malformed JSON is returned by server") {
                let token = TokenBuilder(response: .createGetInfoConversations).post.build
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseError: Error?
                
                _ = self.client.conversation.new(self.conversationName, withJoin: false).subscribe(onError: { error in
                    responseError = error
                })
                
                expect(responseError).toEventuallyNot(beNil())
            }
        }
    }
}
