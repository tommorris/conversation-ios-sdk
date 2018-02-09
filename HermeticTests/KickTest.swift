//
//  KickTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class KickTest: QuickSpec {
    
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
        
        context("issue kick") {
            it("should pass for peer member") {
                BasicOperations.login(with: self.client)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                let peerMember = conversation.members[1]
                
                var responseStatus: Bool?
                
                _ = peerMember.kick().subscribe(onSuccess: { _ in
                    responseStatus = true
                }, onError: { _ in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
            }
            
            it("should pass for self") {
                BasicOperations.login(with: self.client)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                guard let selfMember = conversation.members.first else { return fail() }
                
                var responseStatus: Bool?
                
                _ = selfMember.kick().subscribe(onSuccess: { _ in
                    responseStatus = true
                }, onError: { _ in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
            }
        }
        
        context("receive kick") {
            it("should pass for self") {
                guard let token = ["template": "default,left,event-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue.uppercased(),
                                     MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue,
                                     MemberModel.State.left.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.left.rawValue],
                                   "user_name_left": TestConstants.User.name,
                                   "user_id_left": TestConstants.User.uuid,
                                   "member_id_left": TestConstants.Member.uuid,
                                   "cid_left": TestConstants.Conversation.uuid,
                                   "wait": 4].JSONString else { return fail() }
                
                var memberLeft: Member?
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.memberLeft.addHandler { member in memberLeft = member }
                
                expect(memberLeft?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(memberLeft?.state).toEventually(equal(.left))
                expect(memberLeft?.user.name).toEventually(equal(TestConstants.User.name))
                expect(memberLeft?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(memberLeft?.conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(memberLeft?.conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(memberLeft?.conversation.state).toEventually(equal(.left))
                expect(memberLeft?.conversation.creationDate).toEventuallyNot(beNil())
                expect(memberLeft?.conversation.members.count).toEventually(equal(2))
                expect(memberLeft?.conversation.members[0].state).toEventually(equal(.left))
            }
            
            it("should pass for peer member") {
                guard let token = ["template": "default,left,event-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue.uppercased(),
                                     MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue,
                                     MemberModel.State.left.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.left.rawValue],
                                   "user_name_left": TestConstants.PeerUser.name,
                                   "user_id_left": TestConstants.PeerUser.uuid,
                                   "member_id_left": TestConstants.PeerMember.uuid,
                                   "cid_left": TestConstants.Conversation.uuid,
                                   "wait": 4].JSONString else { return fail() }
                
                var memberLeft: Member?
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.memberLeft.addHandler { member in memberLeft = member }
                
                expect(memberLeft?.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(memberLeft?.state).toEventually(equal(.left))
                expect(memberLeft?.user.name).toEventually(equal(TestConstants.PeerUser.name))
                expect(memberLeft?.user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(memberLeft?.conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(memberLeft?.conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(memberLeft?.conversation.state).toEventually(equal(.left))
                expect(memberLeft?.conversation.creationDate).toEventuallyNot(beNil())
                expect(memberLeft?.conversation.members.count).toEventually(equal(2))
                expect(memberLeft?.conversation.members[1].state).toEventually(equal(.left))
            }
            
            it("should fail for unknown member") {
                guard let token = ["template": "default,left",
                                   "user_name_left": "UNKNOWN-NAME",
                                   "user_id_left": "UNKNOWN-USER-ID",
                                   "member_id_left": "UNKNOWN-MEMBER",
                                   "cid_left": TestConstants.Conversation.uuid,
                                   "wait": 4].JSONString else { return fail() }
                
                var memberLeft: Member?
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.memberLeft.addHandler { member in memberLeft = member }
                
                expect(memberLeft).toEventually(beNil())
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members[0].state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members[1].state).toEventually(equal(MemberModel.State.joined))
            }
            
            it("should expose left conversation for self") {
                guard let token = ["template": "default,left,event-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue.uppercased(),
                                     MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue,
                                     MemberModel.State.left.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.left.rawValue],
                                   "user_name_left": TestConstants.User.name,
                                   "user_id_left": TestConstants.User.uuid,
                                   "member_id_left": TestConstants.Member.uuid,
                                   "cid_left": TestConstants.Conversation.uuid,
                                   "wait": 4].JSONString else { return fail() }
                
                var conversationLeft: Conversation?
                
                _ = self.client.conversation.conversations.asObservable.subscribe(onNext: { change in
                    switch change {
                    case .inserted(let conversation, let reason):
                        switch reason {
                        case .modified: conversationLeft = conversation
                        default: break
                        }
                    default: break
                    }
                })
                
                var memberLeft: Member?
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                conversation.memberLeft.addHandler { member in memberLeft = member }
                
                expect(memberLeft?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(memberLeft?.state).toEventually(equal(.left))
                expect(memberLeft?.user.name).toEventually(equal(TestConstants.User.name))
                expect(memberLeft?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(memberLeft?.conversation.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(memberLeft?.conversation.name).toEventually(equal(TestConstants.Conversation.name))
                expect(memberLeft?.conversation.state).toEventually(equal(.left))
                expect(memberLeft?.conversation.creationDate).toEventuallyNot(beNil())
                expect(memberLeft?.conversation.members.count).toEventually(equal(2))
                expect(memberLeft?.conversation.members[0].state).toEventually(equal(.left))
                
                expect(conversationLeft?.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversationLeft?.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversationLeft?.state).toEventually(equal(.left))
                expect(conversationLeft?.members.count).toEventually(equal(2))
            }
        }
        
        context("leave") {
            it("should pass") {
                guard let token = ["state": ["getinfo_setinfo_delete_conversation":
                    [MemberModel.State.joined.rawValue.uppercased(),
                     MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue,
                                     MemberModel.State.left.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.left.rawValue]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseStatus: Bool?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                _ = conversation.leave().subscribe(onSuccess: { _ in
                    responseStatus = true
                }, onError: { _ in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.left))
            }
            
            it("should add date to member") {
                guard let token = ["template": "event-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue.uppercased(),
                                     MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue,
                                     MemberModel.State.left.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.left.rawValue]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseStatus: Bool?
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.first?.state).toEventually(equal(.joined))
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                
                _ = conversation.leave().subscribe(onSuccess: {
                    responseStatus = true
                })
                
                expect(responseStatus).toEventually(beTrue())
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.left)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.left)).toEventuallyNot(beNil())
            }
            
            it("should expose left conversation for self") {
                guard let token = ["state": ["getinfo_setinfo_delete_conversation":
                    [MemberModel.State.joined.rawValue.uppercased(),
                     MemberModel.State.left.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.left.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.joined.rawValue,
                                     MemberModel.State.left.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.left.rawValue]].JSONString else { return fail() }
                
                var conversationLeft: Conversation?
                
                _ = self.client.conversation.conversations.asObservable.subscribe(onNext: { change in
                    switch change {
                    case .inserted(let conversation, let reason):
                        switch reason {
                        case .modified: conversationLeft = conversation
                        default: break
                        }
                    default: break
                    }
                })
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseStatus: Bool?
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                _ = conversation.leave().subscribe(onSuccess: { _ in
                    responseStatus = true
                }, onError: { _ in
                    fail()
                })
                
                expect(responseStatus).toEventually(beTrue())
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.left))
                
                expect(conversationLeft?.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversationLeft?.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversationLeft?.state).toEventually(equal(.left))
                expect(conversationLeft?.members.count).toEventually(equal(2))
            }
        }
    }
}
