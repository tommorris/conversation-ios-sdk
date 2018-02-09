//
//  TextTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import NexmoConversation

class TextTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    let client = ConversationClient.instance
    
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 5
        Nimble.AsyncDefaults.PollInterval = 1
        
        beforeEach {            
        }
        
        afterEach {
            // Todo: Better way to stop worker threads
            expect(self.client.storage.databaseManager.task.pending.count).toEventually(equal(0))
            BasicOperations.logout(client: self.client)
        }
        
        context("send text") {
            it("should pass") {
                guard let token = ["text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid].JSONString else { return fail() }

                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: TextEvent?
                
                let conversation = self.client.conversation.conversations.first
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation?.events.eventSent.addHandler {
                        returnedEvent = $0 as? TextEvent
                        done()
                    }
                    _ = try? conversation?.send(TestConstants.Text.text)
                }
                
                expect(returnedEvent?.text?.isEmpty).toEventually(beFalse())
            }
            
            it("should create a temporary draft event") {
                guard let token = ["text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                var receivedEvent: TextEvent?
                
                conversation.events.newEventReceived.addHandler { event in
                    guard let textEvent = event as? TextEvent else {
                        return fail()
                    }
                    receivedEvent = textEvent
                }
                
                guard (try? conversation.send(TestConstants.Text.text)) != nil else { return fail() }

                // Returned event is draft
                expect(receivedEvent).toEventuallyNot(beNil())
                guard let textEvent = receivedEvent else { return fail() }
                
                expect(textEvent.isCurrentlyBeingSent).toEventually(beTrue())
                expect(conversation.events.last?.uuid).to(equal(textEvent.uuid))
                
                // eventually we receive new event and remove draft
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation.events.newEventReceived.addHandler { _ in
                        done()
                    }
                }
                expect(conversation.events.last?.isCurrentlyBeingSent).toEventually(beFalse())
                expect(conversation.events.contains(textEvent)).toEventuallyNot(beTrue())

                // and we expect new event to be final text event
                expect((conversation.events.last as? TextEvent)?.text).toEventually(equal(TestConstants.Text.text))
                expect(conversation.events.last?.uuid).toEventually(equal("\(TestConstants.Conversation.uuid):\(TestConstants.Text.uuid)"))
            }
            
            it("should fail when malformed JSON is returned by server") {
                let token = TokenBuilder(response: .sendGetRangeEvents).post.build
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                
                self.client.conversation.conversations.first?.events.eventSent.addHandler { event in
                    returnedEvent = event
                }
                
                _ = try? self.client.conversation.conversations.first?.send(TestConstants.Text.text)
                
                expect(returnedEvent).toEventually(beNil())
            }
            
            it("should fail when text is empty") {
                BasicOperations.login(with: self.client)
                
                var returnedEvent: EventBase?
                
                self.client.conversation.conversations.first?.events.eventSent.addHandler { event in
                    returnedEvent = event
                }
                
                _ = try? self.client.conversation.conversations.first?.send("")
                
                expect(returnedEvent).toEventually(beNil())
            }
            
            it("receipt should not be created") {
                guard let token = ["text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                
                let conversation = self.client.conversation.conversations.first
                
                conversation?.events.newEventReceived.addHandler {
                    returnedEvent = $0 as? TextEvent
                }
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation?.events.eventSent.addHandler { _ in
                        done()
                    }
                    _ = try? conversation?.send(TestConstants.Text.text)
                }
                
                expect((returnedEvent as? TextEvent)?.allReceipts.count).toEventually(equal(0))
            }
            
            it("isCurrentlyBeingSent should be true") {
                guard let token = ["text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid].JSONString else { return fail() }

                BasicOperations.login(with: self.client, using: token)

                let conversation = self.client.conversation.conversations.first

                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation?.events.eventSent.addHandler { _ in
                        done()
                    }
                    _ = try? conversation?.send(TestConstants.Text.text)
                }

                expect(
                    conversation?.events.contains(where: { ($0 as? TextEvent)?.isCurrentlyBeingSent == true }
                )).toEventually(beTrue())
            }
            
            it("should pass for newly joined conversation") {
                guard let token = ["template": "default,invited,conversation-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                                [MemberModel.State.invited.rawValue.uppercased(),
                                                 MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": TestConstants.User.uuid,
                                   "peer_member_id": TestConstants.Member.uuid,
                                   "peer_user_name": TestConstants.User.name,
                                   "text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid,
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var textSent: TextEvent?
                var responseStatus: Bool?
                
                expect(self.client.conversation.conversations.first).toEventuallyNot(beNil())
                let conversation = self.client.conversation.conversations.first
                
                expect(conversation?.state).toEventually(equal(MemberModel.State.invited))

                _ = conversation?.join().subscribe(onSuccess: {
                    responseStatus = true
                })
                
                expect(responseStatus).toEventually(beTrue())
                conversation?.events.newEventReceived.addHandler({ text in
                    textSent = text as? TextEvent
                })
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation?.events.eventSent.addHandler { _ in
                        done()
                    }
                    _ = try? conversation?.send(TestConstants.Text.text)
                }
                
                expect(textSent).toEventuallyNot(beNil())
                expect(textSent?.text).toEventually(equal(TestConstants.Text.text))
            }
            
            it("should change conversations order for multiple conversations") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-multi-known-cid",
                                                "getinfo_setinfo_delete_conversation": "conversation-random-member",
                                                "send_getrange_events": "event-list-empty"],
                                   "text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(2))
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                
                let conversation = self.client.conversation.conversations[1]

                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation.events.eventSent.addHandler { _ in
                        done()
                    }
                    _ = try? conversation.send(TestConstants.Text.text)
                }
                
                expect(self.client.conversation.conversations[0].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
            }
        }
        
        context("receive text") {
            it("should pass") {                
                var responseText: TextEvent?
                
                guard let token = ["template": "default,text",
                                   "from": TestConstants.PeerMember.uuid,
                                   "text_event_id": TestConstants.Text.uuid,
                                   "wait": "4"].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                self.client.conversation.conversations.first?.events.newEventReceived.addHandler { event in
                    responseText = event as? TextEvent
                }
                
                expect(self.client.conversation.conversations.first?.events.count).toEventually(equal(5))
                expect(responseText).toEventuallyNot(beNil())
                expect(responseText?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(responseText?.from.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
            }
            
            it("receipt should be created") {
                guard let token = ["template": "default,text",
                                   "from": TestConstants.PeerMember.uuid,
                                   "text_event_id": TestConstants.Text.uuid,
                                   "wait": "3"].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseText: EventBase?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.events.newEventReceived.addHandler { event in
                    responseText = event
                }
                
                expect(responseText).toEventuallyNot(beNil())
                expect((responseText as? TextEvent)?.allReceipts.count).toEventually(equal(1))
            }
            
            it("should change conversations order for multiple conversations") {
                guard let token = ["template": ["session:success": "default,text",
                                                "get_user_conversation_list": "conversation-list-multi-known-cid",
                                                "send_getrange_events": "event-list-empty"],
                                   "from": TestConstants.PeerMember.uuid,
                                   "text_event_id": TestConstants.Text.uuid,
                                   "wait": "3"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(2))
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                
                expect(self.client.conversation.conversations[1].events.count).toEventually(equal(1))
                
                expect(self.client.conversation.conversations[0].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
            }
        }
    }
}
