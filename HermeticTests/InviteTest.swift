//
//  InviteTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class InviteTest: QuickSpec {
    
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
        
        context("invite") {
            it("should pass from retrieved conversation") {
                BasicOperations.login(with: self.client)

                var responseStatus: Bool?
                guard let conversation = self.client.conversation.conversations.first else { return fail() }

                _ = conversation.invite(TestConstants.PeerUser.name).subscribe(onSuccess: {
                    responseStatus = true
                }, onError: { error in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversation.creationDate).toEventuallyNot(beNil())
            }
            
            it("should pass for empty string as username") {
                BasicOperations.login(with: self.client)
                
                var responseStatus: Bool?
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                _ = conversation.invite("").subscribe(onSuccess: {
                    responseStatus = true
                }, onError: { error in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversation.creationDate).toEventuallyNot(beNil())
            }
            
            it("should pass for special character string as username") {
                BasicOperations.login(with: self.client)
                
                var responseStatus: Bool?
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                _ = conversation.invite("!@#$%^&*()_+-={}:|`~<>,.?/§±").subscribe(onSuccess: {
                    responseStatus = true
                }, onError: { error in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversation.creationDate).toEventuallyNot(beNil())
            }
        }
        
        context("receive invitation") {
            it("should pass") {
                guard let token = ["template": ["session:success": "default,invited",
                                                "get_user_conversation_list": "conversation-list-empty"],
                                   "state": MemberModel.State.invited.rawValue.uppercased(),
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": ["session:success": TestConstants.User.uuid],
                                   "peer_member_id": ["session:success": TestConstants.Member.uuid],
                                   "peer_user_name": ["session:success": TestConstants.User.name],
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation).toEventuallyNot(beNil())
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .invited }).count).toEventually(equal(2))
                expect(conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid + "-invited"))
                expect(conversation.creationDate).toEventuallyNot(beNil())
            }
            
            it("should pass when user accepts it") {
                guard let token = ["template": ["session:success": "default,invited",
                                                "get_user_conversation_list": "conversation-list-empty"],
                                   "state": ["getinfo_setinfo_delete_conversation":
                                                [MemberModel.State.invited.rawValue.uppercased(),
                                                 MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": ["session:success": TestConstants.User.uuid],
                                   "peer_member_id": ["session:success": TestConstants.Member.uuid],
                                   "peer_user_name": ["session:success": TestConstants.User.name],
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseStatus: Bool?
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation).toEventuallyNot(beNil())
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                
                _ = conversation.join().subscribe(onSuccess: {
                    responseStatus = true
                })

                expect(responseStatus).toEventually(beTrue())
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.filter({ $0.state == .joined }).count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .joined }).first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.filter({ $0.state == .joined })[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
            
            it("should pass when user rejects it") {
                guard let token = ["template": "default,invited,conversation-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                                [MemberModel.State.invited.rawValue.uppercased(),
                                                 MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": ["session:success": TestConstants.User.uuid],
                                   "peer_member_id": ["session:success": TestConstants.Member.uuid],
                                   "peer_user_name": ["session:success": TestConstants.User.name],
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseStatus: Bool?
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation).toEventuallyNot(beNil())
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                
                _ = conversation.leave().subscribe(onSuccess: { _ in
                    responseStatus = true
                }, onError: { _ in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members.filter({ $0.state == .left }).count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .left }).first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.filter({ $0.state == .left })[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
            
            it("invited_by field should be exposed") {
                guard let token = ["template": "default,invited,conversation-list-empty,event-list-empty,conversation-invitedby",
                                   "state": MemberModel.State.invited.rawValue.uppercased(),
                                   "timestamp_state": MemberModel.State.invited.rawValue,
                                   "cname": "CON-sdk-test-invited",
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": ["session:success": TestConstants.User.uuid],
                                   "peer_member_id": ["session:success": TestConstants.Member.uuid],
                                   "peer_user_name": ["session:success": TestConstants.User.name],
                                   "by_user_name": TestConstants.PeerUser.name,
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                var invitedByMember: Member?
                
                _ = self.client.conversation.conversations.asObservable.subscribe(onNext: { change in
                    switch change {
                    case .inserted(_, let reason):
                        switch reason {
                        case .invitedBy(let member, _):
                            invitedByMember = member
                        default: break
                        }
                    default: break
                    }
                })
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(invitedByMember).toEventuallyNot(beNil())
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation).toEventuallyNot(beNil())
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.members.filter({ $0.state == .invited }).count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .invited }).first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.filter({ $0.state == .invited })[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
            }
            
            it("should not add conversation to list if for another member") {
                guard let token = ["template": "default,invited,conversation-list-empty",
                                   "wait": ["session:success": "2"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                // unfortunately quick/nimble does not have explicit wait like mockito, so using sleep here :/
                sleep(2)
                expect(self.client.conversation.conversations.count).toEventually(equal(0))
            }
        }
    }
}
