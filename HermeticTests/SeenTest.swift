//
//  SeenTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import NexmoConversation

class SeenTest: QuickSpec {
    
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
        
        context("mark as seen") {
            it("should pass for text from event history") {
                guard let token = ["event_id": 3].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let text = conversation.events.last as? TextEvent
                
                var receiptRecord: ReceiptRecord?
                
                text?.receiptRecordChanged.addHandler { receipt in
                    receiptRecord = receipt
                }

                let seen = text?.markAsSeen()

                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.Member.uuid))

                expect(seen).toEventually(beTrue())
                expect(text?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":3"))
                expect(text?.allReceipts.count).toEventually(equal(1))
                expect(text?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(text?.allReceipts.first?.state).toEventually(equal(.seen))
                expect(text?.allReceipts.first?.date).toEventuallyNot(beNil())
                expect(text?.allReceipts.first?.event.uuid).toEventually(equal(text?.uuid))
                expect(text?.allReceipts.first?.event.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(text?.allReceipts.first?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(text?.allReceipts.first?.member.state).toEventually(equal(.joined))
                expect(text?.allReceipts.first?.member.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(text?.allReceipts.first?.member.user.name).toEventually(equal(TestConstants.User.name))
            }
            
            it("should pass for image from event history") {
                guard let token = ["template": "event-list-image", "event_id": 3].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let image = conversation.events.last as? ImageEvent
                
                var receiptRecord: ReceiptRecord?
                
                image?.receiptRecordChanged.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                let seen = image?.markAsSeen()
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                
                expect(seen).toEventually(beTrue())
                expect(image?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":3"))
                expect(image?.allReceipts.count).toEventually(equal(1))
                expect(image?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(image?.allReceipts.first?.state).toEventually(equal(.seen))
                expect(image?.allReceipts.first?.date).toEventuallyNot(beNil())
                expect(image?.allReceipts.first?.event.uuid).toEventually(equal(image?.uuid))
                expect(image?.allReceipts.first?.event.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(image?.allReceipts.first?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(image?.allReceipts.first?.member.state).toEventually(equal(.joined))
                expect(image?.allReceipts.first?.member.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(image?.allReceipts.first?.member.user.name).toEventually(equal(TestConstants.User.name))
            }
            
            it("should pass for received text") {
                guard let token = ["template": "default,text",
                                   "from": TestConstants.PeerMember.uuid,
                                   "text_event_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid,
                                   "wait": 3].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(5))
                
                let text = conversation.events.last as? TextEvent
                
                var receiptRecord: ReceiptRecord?
                
                text?.receiptRecordChanged.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                let seen = text?.markAsSeen()
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                
                expect(seen).toEventually(beTrue())
                expect(text?.allReceipts.count).toEventually(equal(1))
                expect(text?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(text?.allReceipts.first?.state).toEventually(equal(.seen))
                expect(text?.allReceipts.first?.date).toEventuallyNot(beNil())
                expect(text?.allReceipts.first?.event.uuid).toEventually(equal(text?.uuid))
                expect(text?.allReceipts.first?.event.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(text?.allReceipts.first?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(text?.allReceipts.first?.member.state).toEventually(equal(.joined))
                expect(text?.allReceipts.first?.member.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(text?.allReceipts.first?.member.user.name).toEventually(equal(TestConstants.User.name))
            }
            
            it("should pass for received image") {
                guard let token = ["template": "default,image",
                                   "from": TestConstants.PeerMember.uuid,
                                   "image_event_id": TestConstants.Image.uuid,
                                   "event_id": TestConstants.Image.uuid,
                                   "wait": 3].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(5))
                
                let image = conversation.events.last as? ImageEvent
                
                var receiptRecord: ReceiptRecord?
                
                image?.receiptRecordChanged.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                let seen = image?.markAsSeen()
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                
                expect(seen).toEventually(beTrue())
                expect(image?.allReceipts.count).toEventually(equal(1))
                expect(image?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(image?.allReceipts.first?.state).toEventually(equal(.seen))
                expect(image?.allReceipts.first?.date).toEventuallyNot(beNil())
                expect(image?.allReceipts.first?.event.uuid).toEventually(equal(image?.uuid))
                expect(image?.allReceipts.first?.event.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(image?.allReceipts.first?.member.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(image?.allReceipts.first?.member.state).toEventually(equal(.joined))
                expect(image?.allReceipts.first?.member.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(image?.allReceipts.first?.member.user.name).toEventually(equal(TestConstants.User.name))
            }
            
            it("user should not be able to mark as seen own text") {
                BasicOperations.login(with: self.client)
                
                var seenResponse = false

                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                guard let textEvent = conversation.events.last as? TextEvent else { return fail() }
                
                textEvent.markAsSeen()

                conversation.events.events.addHandler { _ in
                    seenResponse = true
                }

                expect(seenResponse).toEventually(beFalse())
            }
            
            it("user should not be able to mark as seen same text twice") {
                BasicOperations.login(with: self.client)
                
                guard let textEvent = self.client.conversation.conversations.first?.events.last as? TextEvent else { return fail() }
                
                let seen1 = textEvent.markAsSeen()
                let seen2 = textEvent.markAsSeen()
                
                expect(textEvent).toEventuallyNot(beNil())
                expect(seen1).toEventually(beTrue())
                expect(seen2).toEventually(beFalse())
            }
        }
        
        context("receive a seen event") {
            it("should pass in case of sent text") {
                var responseText: TextEvent?
                var receiptRecord: ReceiptRecord?
                
                guard let token = ["template": "default,text_seen",
                                   "text_id": TestConstants.Text.uuid,
                                   "event_id": TestConstants.Text.uuid,
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": TestConstants.Text.uuid,
                                   "wait": 5].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                let conversation = self.client.conversation.conversations.first
                conversation?.events.newEventReceived.addHandler { responseText = $0 as? TextEvent }
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation?.events.eventSent.addHandler { _ in
                        done()
                    }
                    guard let _ = try? conversation?.send(TestConstants.Text.text) == nil else { return fail() }
                }
                
                expect(responseText).toEventuallyNot(beNil(), timeout: 10, pollInterval: 1)
                expect(responseText?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(responseText?.from.uuid).toEventually(equal(TestConstants.User.uuid))
                
                responseText?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
            
            it("should pass in case of sent image") {
                var responseImage: ImageEvent?
                var receiptRecord: ReceiptRecord?
                
                guard let token = ["template": "default,image_seen",
                                   "image_id": TestConstants.Image.uuid,
                                   "event_id": TestConstants.Image.uuid,
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": TestConstants.Image.uuid,
                                   "wait": 5].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                conversation.events.newEventReceived.addHandler { responseImage = $0 as? ImageEvent }
                
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    conversation.events.eventSent.addHandler { _ in
                        done()
                    }
                    guard let _ = try? conversation.send(data) else { return fail() }
                }
                
                expect(responseImage).toEventuallyNot(beNil(), timeout: 10, pollInterval: 1)
                expect(responseImage?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(responseImage?.from.uuid).toEventually(equal(TestConstants.User.uuid))
                
                responseImage?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
            
            it("should pass in case of text from event history") {
                guard let token = ["template": "default,text_seen",
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": 2,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let text = conversation.events[2] as? TextEvent
                
                var receiptRecord: ReceiptRecord?
                
                text?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                
                expect(text?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(text?.allReceipts.count).toEventually(equal(1))
                expect(text?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(text?.allReceipts.first?.state).toEventually(equal(.seen))
            }
            
            it("should pass in case of image from event history") {
                guard let token = ["template": "default,image_seen,event-list-image",
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": 2,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let image = conversation.events[2] as? ImageEvent
                
                var receiptRecord: ReceiptRecord?
                
                image?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventuallyNot(beNil())
                expect(receiptRecord?.date).toEventuallyNot(beNil())
                expect(receiptRecord?.state).toEventually(equal(.seen))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                
                expect(image?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(image?.allReceipts.count).toEventually(equal(1))
                expect(image?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(image?.allReceipts.first?.state).toEventually(equal(.seen))
            }
            
            it("should fail in case of unknown text") {
                guard let token = ["template": "default,text_seen",
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": 10,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let text = conversation.events[2] as? TextEvent
                
                var receiptRecord: ReceiptRecord?
                
                text?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventually(beNil())
                
                expect(text?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(text?.allReceipts.count).toEventually(equal(0))
                expect(text?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(text?.allReceipts.first?.state).toEventually(beNil())
            }
            
            it("should fail in case of unknown image") {
                guard let token = ["template": "default,image_seen,event-list-image",
                                   "image_id": TestConstants.Image.uuid,
                                   "event_id": TestConstants.Image.uuid,
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": 10,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let image = conversation.events[2] as? ImageEvent
                
                var receiptRecord: ReceiptRecord?
                
                image?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventually(beNil())
                
                expect(image?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(image?.allReceipts.count).toEventually(equal(0))
                expect(image?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(image?.allReceipts.first?.state).toEventually(beNil())
            }
            
            it("should fail in case of unknown member for text") {
                guard let token = ["template": "default,text_seen",
                                   "seen_from": "UNKNOWN-MEM",
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": 2,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let text = conversation.events[2] as? TextEvent
                
                var receiptRecord: ReceiptRecord?
                
                text?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventually(beNil())
                
                expect(text?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(text?.allReceipts.count).toEventually(equal(0))
                expect(text?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(text?.allReceipts.first?.state).toEventually(beNil())
            }
            
            it("should fail in case of unknown member for image") {
                guard let token = ["template": "default,image_seen,event-list-image",
                                   "seen_from": "UNKNOWN-MEM",
                                   "seen_cid": TestConstants.Conversation.uuid,
                                   "seen_event_id": 2,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let image = conversation.events[2] as? ImageEvent
                
                var receiptRecord: ReceiptRecord?
                
                image?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventually(beNil())
                
                expect(image?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(image?.allReceipts.count).toEventually(equal(0))
                expect(image?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(image?.allReceipts.first?.state).toEventually(beNil())
            }
            
            it("should fail in case of unknown conversation for text") {
                guard let token = ["template": "default,text_seen",
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": "UNKNOWN-CID",
                                   "seen_event_id": 2,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let text = conversation.events[2] as? TextEvent
                
                var receiptRecord: ReceiptRecord?
                
                text?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventually(beNil())
                
                expect(text?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(text?.allReceipts.count).toEventually(equal(0))
                expect(text?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(text?.allReceipts.first?.state).toEventually(beNil())
            }
            
            it("should fail in case of unknown conversation for image") {
                guard let token = ["template": "default,image_seen,event-list-image",
                                   "seen_from": TestConstants.PeerMember.uuid,
                                   "seen_cid": "UNKNOWN-CID",
                                   "seen_event_id": 2,
                                   "wait": 5].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.events.count).toEventually(equal(4))
                
                let image = conversation.events[2] as? ImageEvent
                
                var receiptRecord: ReceiptRecord?
                
                image?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord).toEventually(beNil())
                
                expect(image?.uuid).toEventually(equal(TestConstants.Conversation.uuid + ":2"))
                expect(image?.allReceipts.count).toEventually(equal(0))
                expect(image?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(image?.allReceipts.first?.state).toEventually(beNil())
            }
        }
    }
}
