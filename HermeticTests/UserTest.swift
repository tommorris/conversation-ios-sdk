//
//  UserTest.swift
//  NexmoConversation
//
//  Created by Ivan on 24/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class UserTest: QuickSpec {
    
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
        
        context("get user details") {
            it("should pass for self if part of conversation") {
                BasicOperations.login(with: self.client)
                
                var responseUser: User?
                
                self.client.account.user(with: TestConstants.User.uuid, { user in
                    responseUser = user
                }, onFailure: { error in
                    fail()
                })
                
                expect(responseUser).toEventuallyNot(beNil())
                expect(responseUser?.isMe).toEventually(beTrue())
                expect(responseUser?.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(responseUser?.displayName).toEventually(equal(TestConstants.User.name))
                expect(responseUser?.name).toEventually(equal(TestConstants.User.name))
            }
            
            it("should pass for self if not part of conversation") {
                guard let token = ["template": "conversation-list-empty"].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseUser: User?
                
                self.client.account.user(with: TestConstants.User.uuid, { user in
                    responseUser = user
                }, onFailure: { error in
                    fail()
                })
                
                expect(responseUser).toEventuallyNot(beNil())
                expect(responseUser?.isMe).toEventually(beTrue())
                expect(responseUser?.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(responseUser?.displayName).toEventually(equal(TestConstants.User.name))
                expect(responseUser?.name).toEventually(equal(TestConstants.User.name))
            }
            
            it("should pass for another user if part of conversation") {
                BasicOperations.login(with: self.client)
                
                var responseUser: User?
                
                self.client.account.user(with: TestConstants.PeerUser.uuid, { user in
                    responseUser = user
                }, onFailure: { error in
                    fail()
                })
                
                expect(responseUser).toEventuallyNot(beNil())
                expect(responseUser?.isMe).toEventually(beFalse())
                expect(responseUser?.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(responseUser?.displayName).toEventually(equal(TestConstants.PeerUser.name))
                expect(responseUser?.name).toEventually(equal(TestConstants.PeerUser.name))
            }
            
            it("should pass for another user if not part of conversation") {
                guard let token = ["template": "conversation-list-empty"].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseUser: User?
                
                self.client.account.user(with: TestConstants.PeerUser.uuid, { user in
                    responseUser = user
                }, onFailure: { error in
                    fail()
                })
                
                expect(responseUser).toEventuallyNot(beNil())
                expect(responseUser?.isMe).toEventually(beFalse())
                expect(responseUser?.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(responseUser?.displayName).toEventually(equal(TestConstants.PeerUser.name))
                expect(responseUser?.name).toEventually(equal(TestConstants.PeerUser.name))
            }
        }
        
    }
}
