//
//  DeliveredTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class DeliveredTest: QuickSpec {
    
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
        
        context("received message from another member") {
            it("text should be marked as delivered") {
                var responseText: EventBase?
                
                guard let token = ["template": "default,text",
                                   "from": TestConstants.PeerMember.uuid,
                                   "cid": TestConstants.Conversation.uuid,
                                   "wait": "3",
                                   "text_event_id": 5].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                let conversation = self.client.conversation.conversations.first
                
                conversation?.events.newEventReceived.addHandler { event in
                    responseText = event
                }
                
                expect(responseText).toEventuallyNot(beNil())
                expect((responseText as? TextEvent)?.allReceipts.count).toEventually(equal(1))
                
                guard let receiptDelivered = (responseText as? TextEvent)?.allReceipts.first else { return fail() }
                
                expect(receiptDelivered.state.rawValue).toEventually(equal(ReceiptState.delivered.rawValue))
                expect(receiptDelivered.date).toEventuallyNot(beNil())
            }
            
            it("image should be marked as delivered") {
                var responseImage: EventBase?
                
                guard let token = ["template": "default,image",
                                   "from": TestConstants.PeerMember.uuid,
                                   "cid": TestConstants.Conversation.uuid,
                                   "wait": "3",
                                   "image_event_id": 5].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                let conversation = self.client.conversation.conversations.first
                
                conversation?.events.newEventReceived.addHandler { event in
                    responseImage = event
                }
                
                expect(responseImage).toEventuallyNot(beNil())
                expect((responseImage as? TextEvent)?.allReceipts.count).toEventually(equal(1))
                
                guard let receiptDelivered = (responseImage as? ImageEvent)?.allReceipts.first else { return fail() }
                
                expect(receiptDelivered.state.rawValue).toEventually(equal(ReceiptState.delivered.rawValue))
                expect(receiptDelivered.date).toEventuallyNot(beNil())
            }
        }
        
        context("receive a delivered event for own message") {
            it("should pass in case of text") {
                guard let token = ["template": "default,text_delivered",
                                   "from": TestConstants.PeerMember.uuid,
                                   "cid_delivered": TestConstants.Conversation.uuid,
                                   "delivered_event_id": TestConstants.Text.uuid,
                                   "wait": "5"].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                var receiptRecord: ReceiptRecord?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.events.newEventReceived.addHandler { event in
                    returnedEvent = event
                }
                
                _ = try? conversation.send(TestConstants.Text.text)
                
                expect(conversation.events.count).toEventually(equal(6))
                expect((returnedEvent as? TextEvent)?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                
                (conversation.events[4] as? TextEvent)?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord?.state.rawValue).toEventually(equal(ReceiptState.delivered.rawValue))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
            
            it("should pass in case of image") {
                guard let token = ["template": "default,image_delivered",
                                   "from": TestConstants.PeerMember.uuid,
                                   "cid_delivered": TestConstants.Conversation.uuid,
                                   "delivered_event_id": TestConstants.Image.uuid,
                                   "image_id": TestConstants.Image.uuid,
                                   "wait": "5"].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                var receiptRecord: ReceiptRecord?
                
                // listen for new events
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.events.newEventReceived.addHandler { event in
                    returnedEvent = event
                }
                
                // create event with image
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                // send event
                _ = try? conversation.send(data)
                
                // test
                expect(conversation.events.count).toEventually(equal(6))
                expect((returnedEvent as? ImageEvent)?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                
                (conversation.events[4] as? TextEvent)?.newReceiptRecord.addHandler { receipt in
                    receiptRecord = receipt
                }
                
                expect(receiptRecord?.state.rawValue).toEventually(equal(ReceiptState.delivered.rawValue))
                expect(receiptRecord?.member.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
        }
    }
}
