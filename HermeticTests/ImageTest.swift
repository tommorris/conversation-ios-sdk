//
//  ImageTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import NexmoConversation

class ImageTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    let client = ConversationClient.instance
    
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 5
        Nimble.AsyncDefaults.PollInterval = 1
        
        beforeEach {
            
        }
        
        afterEach {
            expect(self.client.storage.databaseManager.task.pending.count).toEventually(equal(0))
            BasicOperations.logout(client: self.client)
        }
        
        context("send image") {
            it("should pass") {
                // login
                guard let token = ["template": "event-list-empty",
                                   "event_id": TestConstants.Image.uuid,
                                   "image_id": TestConstants.Image.uuid].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                // listen for new events
                conversation.events.newEventReceived.addHandler { event in
                    returnedEvent = event
                }
                
                // create event with image
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                // send event
                guard let _ = try? conversation.send(data) else { return fail() }
                
                // test
                expect((returnedEvent as? ImageEvent)?.image).toEventuallyNot(beNil())
                expect((returnedEvent as? ImageEvent)?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
            }
            
            it("should fail when malformed JSON is returned by server") {
                let token = TokenBuilder(response: .sendGetRangeEvents).post.build

                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                // listen for new events
                conversation.events.newEventReceived.addHandler { event in
                    returnedEvent = event
                }
                
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                guard let _ = try? conversation.send(data) else { return fail() }
                
                expect(returnedEvent?.uuid.count).toEventuallyNot(beGreaterThan(4), timeout: 15, pollInterval: 1)
            }
            
            it("receipt should not be created") {
                guard let token = ["template": "event-list-empty",
                                   "event_id": TestConstants.Image.uuid,
                                   "image_id": TestConstants.Image.uuid].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: EventBase?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.events.newEventReceived.addHandler { event in
                    returnedEvent = event
                }
                
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                guard let _ = try? conversation.send(data) else { return fail() }
                
                expect((returnedEvent as? ImageEvent)?.allReceipts.count).toEventually(equal(0))
            }
            
            it("should change conversations order for multiple conversations") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-multi-known-cid",
                                                "getinfo_setinfo_delete_conversation": "conversation-random-member",
                                                "send_getrange_events": "event-list-empty"],
                                   "event_id": TestConstants.Image.uuid,
                                   "image_id": TestConstants.Image.uuid].JSONString else {
                                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(2))
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                guard let _ = try? self.client.conversation.conversations[1].send(data) else { return fail() }
                
                expect(self.client.conversation.conversations[0].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
            }
        }
        
        context("receive image") {
            it("should pass") {
                guard let token = ["template": "default,image",
                                   "from": TestConstants.PeerMember.uuid,
                                   "image_event_id": 5,
                                   "wait": ["session:success": "3"]].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseImage: EventBase?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.events.newEventReceived.addHandler { event in
                    responseImage = event
                }
                
                // TODO: test case fails due to there not been sent a conversation
                expect(responseImage).toEventuallyNot(beNil())
                expect(responseImage?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(responseImage?.from.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
            }
            
            it("receipt should be created") {
                guard let token = ["template": "default,image",
                                   "from": TestConstants.PeerMember.uuid,
                                   "image_event_id": 5,
                                   "wait": ["session:success": "3"]].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseImage: EventBase?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.events.newEventReceived.addHandler { event in
                    responseImage = event
                }
                
                // TODO: test case fails due to there not been sent a conversation
                expect(responseImage).toEventuallyNot(beNil())
                expect((responseImage as? ImageEvent)?.allReceipts.count).toEventually(equal(1))
            }
            
            it("should change conversations order for multiple conversations") {
                guard let token = ["template": ["session:success": "default,image",
                                                "get_user_conversation_list": "conversation-list-multi-known-cid",
                                                "send_getrange_events": "event-list-empty",
                                                "getinfo_setinfo_delete_conversation": ["conversation-single-member",
                                                                                        "conversation-random-member"]],
                                   "from": TestConstants.Member.uuid,
                                   "image_event_id": 5,
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(2))
                
                expect(self.client.conversation.conversations[0].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                
                expect(self.client.conversation.conversations[0].uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(self.client.conversation.conversations[1].uuid).toEventuallyNot(equal(TestConstants.Conversation.uuid))
            }
        }
        
        context("download") {
            var imageEvent: ImageEvent?
            var uiImage: UIImage?

            describe("own image") {
                beforeEach {
                    guard let token = ["template": "event-list-empty",
                                       "event_id": TestConstants.Image.uuid,
                                       "image_id": TestConstants.Image.uuid].JSONString else { return fail() }
                    
                    BasicOperations.login(with: self.client, using: token)
                    
                    guard let conversation = self.client.conversation.conversations.first else { return fail() }
                    
                    guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                    guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                    
                    guard let _ = try? conversation.send(data) else { return fail() }
                    
                    expect(conversation.events.count).toEventually(equal(1))
                    expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":4"))
                    
                    imageEvent = conversation.events.last as? ImageEvent
                    
                    expect(imageEvent).toEventuallyNot(beNil())
                    expect(imageEvent?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                }
                
                it("should pass for default thumbnail representation") {
                    imageEvent?.image( { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
                
                it("should pass for own sent image and medium representation") {
                    imageEvent?.image(for: .medium, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
                
                it("should pass for own sent image and original representation") {
                    imageEvent?.image(for: .original, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
            }
            
            describe("received image") {
                beforeEach {
                    guard let token = ["template": ["session:success": "default,image",
                                                    "send_getrange_events": "event-list-empty"],
                                       "from": TestConstants.PeerMember.uuid,
                                       "image_event_id": 5,
                                       "wait": ["session:success": "3"]].JSONString else {
                                        return fail()
                    }
                    
                    BasicOperations.login(with: self.client, using: token)
                    
                    guard let conversation = self.client.conversation.conversations.first else { return fail() }
                    
                    expect(conversation.events.count).toEventually(equal(1))
                    expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":5"))
                    
                    imageEvent = conversation.events.last as? ImageEvent
                    
                    expect(imageEvent).toEventuallyNot(beNil())
                    expect(imageEvent?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                }
                
                it("should pass for default thumbnail representation") {
                    imageEvent?.image( { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
                
                it("should pass for received image and medium representation") {
                    imageEvent?.image(for: .medium, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }

                it("should pass for received image and original representation") {
                    imageEvent?.image(for: .original, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
            }
            
            describe("own synced image") {
                beforeEach {
                    guard let token = ["template": "event-list-image"].JSONString else { return fail() }
                    
                    BasicOperations.login(with: self.client, using: token)
                    
                    guard let conversation = self.client.conversation.conversations.first else { return fail() }
                    
                    expect(conversation.events.count).toEventually(equal(4))
                    expect(conversation.events[2].uuid).toEventually(equal(conversation.uuid + ":2"))
                    
                    imageEvent = conversation.events[2] as? ImageEvent
                    
                    expect(imageEvent).toEventuallyNot(beNil())
                    expect(imageEvent?.fromMember.uuid).toEventually(equal(TestConstants.Member.uuid))
                }
                
                it("should pass for default thumbnail representation") {
                    imageEvent?.image( { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
                
                it("should pass for medium representation") {
                    imageEvent?.image(for: .medium, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
                
                it("should pass for original representation") {
                    imageEvent?.image(for: .original, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
            }
            
            describe("another member's synced image") {
                beforeEach {
                    guard let token = ["template": "event-list-image"].JSONString else { return fail() }
                    
                    BasicOperations.login(with: self.client, using: token)
                    
                    guard let conversation = self.client.conversation.conversations.first else { return fail() }
                    
                    expect(conversation.events.count).toEventually(equal(4))
                    expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":3"))
                    
                    imageEvent = conversation.events.last as? ImageEvent
                    
                    expect(imageEvent).toEventuallyNot(beNil())
                    expect(imageEvent?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                }
                
                it("should pass for default thumbnail representation") {
                    imageEvent?.image( { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }

                it("should pass for medium representation") {
                    imageEvent?.image(for: .medium, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
                
                it("should pass for original representation") {
                    imageEvent?.image(for: .original, { result in
                        switch result {
                        case .success(let newImage): uiImage = newImage
                        default: fail()
                        }
                    })
                    
                    expect(uiImage).toEventuallyNot(beNil())
                }
            }
        
            it("should fail when image service is unavailable") {
                guard let token = ["template": ["session:success": "default,image",
                                                "send_getrange_events": "event-list-empty"],
                                   "from": TestConstants.PeerMember.uuid,
                                   "image_event_id": 5,
                                   "malformed_response": "wrong_code",
                                   "request_method": "GET",
                                   "wait": ["session:success": "3"]].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(1))
                expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":5"))
                
                imageEvent = conversation.events.last as? ImageEvent
                
                expect(imageEvent).toEventuallyNot(beNil())
                expect(imageEvent?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                
                imageEvent?.image(for: .medium, { result in
                    switch result {
                    case .success(let newImage): uiImage = newImage
                    default: break
                    }
                })
                
                expect(uiImage).toEventually(beNil())
            }
            
            it("should fail when malformed image response is received") {
                guard let token = ["template": ["session:success": "default,image",
                                                "send_getrange_events": "event-list-empty"],
                                   "from": TestConstants.PeerMember.uuid,
                                   "image_event_id": 5,
                                   "malformed_response": "malformed_image",
                                   "request_method": "GET",
                                   "wait": ["session:success": "3"]].JSONString else {
                                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(1))
                expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":5"))
                
                imageEvent = conversation.events.last as? ImageEvent
                
                expect(imageEvent).toEventuallyNot(beNil())
                expect(imageEvent?.fromMember.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                
                imageEvent?.image(for: .medium, { result in
                    switch result {
                    case .success(let newImage): uiImage = newImage
                    default: break
                    }
                })
                
                expect(uiImage).toEventually(beNil())
            }
        }
    }
}
