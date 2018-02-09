//
//  DeleteEventTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class DeleteEventTest: QuickSpec {
    
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
        
        context("send delete event") {
            it("should pass for text") {
                guard let token = ["template": ["session:success": "default", "send_getrange_events": "event-list-empty"],
                                   "text_id": 4,
                                   "event_id": "4"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: TextEvent?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                guard let _ = try? conversation.send(TestConstants.Text.text) else { return fail() }
                
                expect((conversation.events.last as? TextEvent)?.isCurrentlyBeingSent).toEventually(beFalse())
                expect(conversation.events.count).toEventually(equal(1))
                
                expect(conversation.events.last?.description).toEventually(equal("TextEvent: 4 from: CON-sdk-test"))
                
                returnedEvent = conversation.events.last as? TextEvent
                
                expect(returnedEvent?.text).toEventually(equal(TestConstants.Text.text))
                
                let success = returnedEvent?.delete()
                
                expect(success).toEventually(beTrue())
                
                expect((conversation.events.last as? TextEvent)?.text).toEventually(beNil())
            }
            
            it("should pass for image") {
                guard let token = ["template": ["session:success": "default", "send_getrange_events": "event-list-empty"],
                                   "image_id": 4,
                                   "event_id": "4"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: ImageEvent?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                guard let _ = try? conversation.send(data) else { return fail() }
                
                expect((conversation.events.last as? TextEvent)?.isCurrentlyBeingSent).toEventually(beFalse())
                expect(conversation.events.count).toEventually(equal(1))

                expect(conversation.events.last?.description).toEventually(equal("ImageEvent: 4 from: CON-sdk-test"))
                
                returnedEvent = conversation.events.last as? ImageEvent
                
                expect(returnedEvent?.image).toEventuallyNot(beNil())
                
                let success = returnedEvent?.delete()
                
                expect(success).to(beTrue())
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    (conversation.events.last as? ImageEvent)?.image({ (image:Result<UIImage>) in
                        switch image {
                        case .success:
                            fail()
                        case .failed:
                            break
                        }
                        done()
                    })
                }
            }
            
            it("should pass for text retrieved on sync") {
                BasicOperations.login(with: self.client)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                guard let myText = conversation.events[2] as? TextEvent else { return fail() }
                
                let success = conversation.delete(myText)
                
                expect(success).toEventually(beTrue())
                
                expect((conversation.events[2] as? TextEvent)?.text).toEventually(beNil())
            }
            
            // TODO: re-enable when image deletion is working
            xit("should pass for image retrieved on sync") {
                guard let token = ["template": "event-list-image"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                guard let myImage = conversation.events[2] as? ImageEvent else { return fail() }
                
                let success = conversation.delete(myImage)
                
                expect(success).to(beTrue())
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    (conversation.events[2] as? ImageEvent)?.image({ (image:Result<UIImage>) in
                        switch image {
                        case .success: fail()
                        case .failed: break
                        }
                        
                        done()
                    })
                }
            }
            
            it("should fail if it is not my text retrieved on sync") {
                guard let token = ["event_id": 3].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                guard let myText = conversation.events.last as? TextEvent else { return fail() }
                
                let success = conversation.delete(myText)
                
                expect(success).to(beFalse())
                
                expect((conversation.events.last as? TextEvent)?.text).toEventuallyNot(beNil())
            }
            
            it("should fail if it is not my image retrieved on sync") {
                guard let token = ["template": "event-list-image", "event_id": 3].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                guard let myImage = conversation.events.last as? ImageEvent else { return fail() }
                
                let success = conversation.delete(myImage)
                
                expect(success).to(beFalse())
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    (conversation.events.last as? ImageEvent)?.image({ (image:Result<UIImage>) in
                        switch image {
                        case .success:
                            break
                        case .failed:
                            fail()
                        }
                        done()
                    })
                }
            }
            
            it("should ignore JSON returned by server") {
                let token = TokenBuilder(response: .setStatusGetDeleteEvent).delete.build
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                guard let myText = conversation.events[2] as? TextEvent else { return fail() }
                
                let success = conversation.delete(myText)
                
                expect(success).toEventually(beTrue())
                
                expect((conversation.events[2] as? TextEvent)?.text).toEventuallyNot(beNil())
            }
        }
        
        context("receive delete event") {
            it("should pass for own retrieved text") {
                guard let token = ["template": "default,event_deleted",
                                   "deleted_event_id": 2,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                expect((conversation.events[2] as? TextEvent)?.text).toNot(beNil())
                
                expect((conversation.events[2] as? TextEvent)?.text).toEventually(beNil())
            }
            
            it("should pass for own retrieved image") {
                guard let token = ["template": "default,event_deleted,event-list-image",
                                   "deleted_event_id": 2,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                expect((conversation.events[2] as? ImageEvent)?.image).toNot(beNil())
                
                expect((conversation.events[2] as? ImageEvent)?.image).toEventually(beNil())
            }
            
            it("should pass for another member retrieved text") {
                guard let token = ["template": "default,event_deleted",
                                   "deleted_event_id": 3,
                                   "from_delete": TestConstants.PeerMember.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                expect((conversation.events.last as? TextEvent)?.text).toNot(beNil())
                
                expect((conversation.events.last as? TextEvent)?.text).toEventually(beNil())
            }
            
            it("should pass for another member retrieved image") {
                guard let token = ["template": "default,event_deleted,event-list-image",
                                   "deleted_event_id": 3,
                                   "from_delete": TestConstants.PeerMember.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                expect((conversation.events.last as? ImageEvent)?.image).toNot(beNil())
                
                expect((conversation.events.last as? ImageEvent)?.image).toEventually(beNil())
            }
            
            it("should pass for sent text") {
                guard let token = ["template": ["session:success":"default,event_deleted", "send_getrange_events": "event-list-empty"],
                                   "text_id": 4,
                                   "deleted_event_id": 4,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: TextEvent?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                guard let _ = try? conversation.send(TestConstants.Text.text) else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(1))
                expect(conversation.events.last?.description).toEventually(equal("TextEvent: 4 from: CON-sdk-test"))
                
                returnedEvent = conversation.events.last as? TextEvent
                
                expect(returnedEvent?.text).toEventually(equal(TestConstants.Text.text))
                
                expect((conversation.events.last as? TextEvent)?.text).toEventually(beNil())
            }
            
            it("should pass for sent image") {
                guard let token = ["template": "default,event_deleted",
                                   "image_id": 4,
                                   "deleted_event_id": 4,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var returnedEvent: ImageEvent?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
                guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
                
                guard let _ = try? conversation.send(data) else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(5))
                expect(conversation.events.last?.description).toEventually(equal("ImageEvent: 4 from: CON-sdk-test"))
                
                returnedEvent = conversation.events.last as? ImageEvent
                
                expect(returnedEvent?.image).toEventuallyNot(beNil())
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    (conversation.events.last as? ImageEvent)?.image({ (image:Result<UIImage>) in
                        switch image {
                        case .success(let image):
                            print(image)
                            fail()
                        case .failed:
                            break
                        }
                        done()
                    })
                }
            }
            
            it("should pass for own received text") {
                guard let token = ["template": "default,text,event_deleted",
                                   "text_event_id": 4,
                                   "deleted_event_id": 4,
                                   "from": TestConstants.Member.uuid,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "3"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(5))
                
                expect((conversation.events.last as? TextEvent)?.text).toEventually(beNil())
            }
            
            it("should pass for own received image") {
                guard let token = ["template": "default,image,event_deleted",
                                   "image_event_id": 4,
                                   "deleted_event_id": 4,
                                   "from": TestConstants.Member.uuid,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "3"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(5))
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    (conversation.events.last as? ImageEvent)?.image({ (image:Result<UIImage>) in
                        switch image {
                        case .success(let image):
                            print(image)
                            fail()
                        case .failed:
                            break
                        }
                        done()
                    })
                }
            }
            
            it("should pass for received text from another member") {
                guard let token = ["template": "default,text,event_deleted",
                                   "text_event_id": 4,
                                   "deleted_event_id": 4,
                                   "from": TestConstants.PeerMember.uuid,
                                   "from_delete": TestConstants.PeerMember.uuid,
                                   "wait": "3"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(5))
                expect((conversation.events.last as? TextEvent)?.allReceipts.count).toEventually(equal(1))
                
                expect((conversation.events.last as? TextEvent)?.text).toEventually(beNil())
            }
            
            it("should pass for received image from another member") {
                guard let token = ["template": "default,image,event_deleted",
                                   "image_event_id": 4,
                                   "deleted_event_id": 4,
                                   "from": TestConstants.PeerMember.uuid,
                                   "from_delete": TestConstants.PeerMember.uuid,
                                   "wait": "3"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(5))
                expect((conversation.events.last as? ImageEvent)?.allReceipts.count).toEventually(equal(1))
                
                waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                    (conversation.events.last as? ImageEvent)?.image({ (image:Result<UIImage>) in
                        switch image {
                        case .success(let image):
                            print(image)
                            fail()
                        case .failed:
                            break
                        }
                        done()
                    })
                }
            }
            
            it("should fail in case of unknown event") {
                guard let token = ["template": "default,event_deleted",
                                   "deleted_event_id": 10,
                                   "from_delete": TestConstants.Member.uuid,
                                   "wait": "5"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.events.count).toEventually(equal(4))
                
                expect((conversation.events[2] as? TextEvent)?.text).toNot(beNil())
                
                expect((conversation.events[2] as? TextEvent)?.text).toEventuallyNot(beNil())
            }
        }
    }
}
