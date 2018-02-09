//
//  JoinTest.swift
//  NexmoConversation
//
//  Created by Ivan on 17/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import NexmoConversation

class JoinTest: QuickSpec {
    
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
        
        context("join") {
            it("should pass") {
                BasicOperations.login(with: self.client)
                
                let model = ConversationController.JoinConversation(userId: TestConstants.User.uuid, memberId: TestConstants.Member.uuid)
                
                var statusResponse: MemberModel.State?
                
                _ = self.client.conversation.join(model, forUUID: TestConstants.Conversation.uuid)
                    .subscribe(onNext: { status in
                        statusResponse = status
                    }, onError: { _ in
                        fail()
                    })
                
                expect(statusResponse?.hashValue).toEventually(equal(MemberModel.State.joined.hashValue))
            }
            
            it("should fail when user is not logged in") {
                let model = ConversationController.JoinConversation(userId: TestConstants.User.uuid, memberId: TestConstants.Member.uuid)
                
                var responseError: Error?
                
                self.client.addAuthorization(with: "")
                _ = self.client.conversation.join(model, forUUID: TestConstants.Conversation.uuid)
                    .subscribe(onError: { error in
                        responseError = error
                    })
                
                expect(responseError).toEventuallyNot(beNil())
            }
            
            it("should pass when member id is empty") {
                BasicOperations.login(with: self.client)
                
                let model = ConversationController.JoinConversation(userId: TestConstants.User.uuid, memberId: nil)
                
                var statusResponse: MemberModel.State?
                
                _ = self.client.conversation.join(model, forUUID: TestConstants.Conversation.uuid)
                    .subscribe(onNext: { status in
                        statusResponse = status
                    }, onError: { _ in
                        fail()
                    })
                
                expect(statusResponse?.rawValue).toEventually(equal(MemberModel.State.joined.rawValue))
            }
            
            it("should fail when user has already joined conversation") {
                guard let token = ["template": "member-already-joined",
                                   "change_state_getinfo_members": 400].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseError: NetworkError?
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                let conversation = self.client.conversation.conversations.first
                
                expect(conversation?.state).toEventually(equal(MemberModel.State.joined))
                
                _ = conversation?.join().subscribe(onError: { error in
                    responseError = error as? NetworkError
                })
                
                expect(responseError).toEventuallyNot(beNil())
                expect(responseError?.code).toEventually(equal(400))
                expect(responseError?.requestURL).toEventually(equal("http://localhost:8888/conversations/CON-sdk-test/members"))
                expect(responseError?.stacktrace).toEventuallyNot(beEmpty())
                expect(responseError?.type).toEventually(equal(NetworkError.Code.Conversation.alreadyJoined.rawValue))
                expect(responseError?.message).toEventually(equal("this user already has a member joined in 'app' type"))
                expect(responseError?.errorDescription).toEventually(equal("this user already has a member joined in 'app' type"))
            }
            
            it("should pass for retrieved conversation") {
                guard let token = ["state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.invited.rawValue.uppercased(),
                                     MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
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
            }
            
            it("should pass for received invitation") {
                guard let token = ["template": ["session:success": "default,invited",
                                                "get_user_conversation_list": "conversation-list-empty"],
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.invited.rawValue.uppercased(),
                                     MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": TestConstants.User.uuid,
                                   "peer_member_id": TestConstants.Member.uuid,
                                   "peer_user_name": TestConstants.User.name,
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
            }
            
            it("should add date to member") {
                guard let token = ["template": ["session:success": "default,invited",
                                                "get_user_conversation_list": "conversation-list-empty",
                                                "send_getrange_events": "event-list-empty",
                                                "getinfo_setinfo_delete_conversation": ["conversation-invitedby", "conversation-invitedby-joined"]],
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.invited.rawValue.uppercased(),
                                     MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.invited.rawValue,
                                     MemberModel.State.joined.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.joined.rawValue],
                                   "cname": "CON-sdk-test-invited",
                                   "cid": "CON-sdk-test-invited",
                                   "peer_user_id": ["session:success": TestConstants.User.uuid],
                                   "peer_member_id": ["session:success": TestConstants.Member.uuid],
                                   "peer_user_name": ["session:success": TestConstants.User.name],
                                   "by_user_name": TestConstants.PeerUser.name,
                                   "wait": ["session:success": "3"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var responseStatus: Bool?
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.members.first?.state).toEventually(equal(.invited))
                expect(conversation.members.first?.date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                
                _ = conversation.join().subscribe(onSuccess: {
                    responseStatus = true
                })
                
                expect(responseStatus).toEventually(beTrue())
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
            }
            
            it("should expose joined conversation for self") {
                guard let token = ["state": ["getinfo_setinfo_delete_conversation":
                    [MemberModel.State.invited.rawValue.uppercased(),
                     MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()]].JSONString else { return fail() }
                
                var conversationJoined: Conversation?
                
                _ = self.client.conversation.conversations.asObservable.subscribe(onNext: { change in
                    switch change {
                    case .inserted(let conversation, let reason):
                        switch reason {
                        case .modified: conversationJoined = conversation
                        default: break
                        }
                    default: break
                    }
                })
                
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
                
                expect(conversationJoined?.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversationJoined?.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversationJoined?.state).toEventually(equal(.joined))
                expect(conversationJoined?.members.count).toEventually(equal(2))
            }
        }
        
        context("receive join") {
            it("should pass for self") {
                guard let token = ["template": ["session:success": "default,login-joined",
                                                "get_user_conversation_list": "conversation-list-empty"],
                                   "userid_joined": TestConstants.User.uuid,
                                   "memberid_joined": TestConstants.Member.uuid,
                                   "username_joined": TestConstants.User.name,
                                   "wait": ["session:success": "5"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                // before receiving member:joined
                expect(self.client.conversation.conversations.count).toEventually(equal(0))
                // after receiving member:joined
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation).toEventuallyNot(beNil())
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
            }
            
            it("should pass for peer member") {
                guard let token = ["template": ["session:success": "default,invited,login-joined",
                                                "getinfo_setinfo_delete_conversation":
                                                    ["conversation-single-member",
                                                     "conversation-invitedby-joined"],
                                                "send_getrange_events": "event-list-empty"],
                                   "userid_joined": TestConstants.PeerUser.uuid,
                                   "memberid_joined": TestConstants.PeerMember.uuid,
                                   "username_joined": TestConstants.PeerUser.name,
                                   "wait": "1"].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                var joinedMember: Member?
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                expect(conversation.members.count).to(equal(1))
                
                conversation.memberJoined.addHandler { member in
                    joinedMember = member
                }
                
                expect(joinedMember).toEventuallyNot(beNil())
                expect(joinedMember?.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(joinedMember?.user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(joinedMember?.user.name).toEventually(equal(TestConstants.PeerUser.name))
                expect(joinedMember?.state).toEventually(equal(.joined))
                expect(conversation.members.count).toEventually(equal(2))
            }
            
            it("should expose joined conversation for self") {
                guard let token = ["template": "default,login-joined,event-list-empty",
                                   "state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.invited.rawValue.uppercased(),
                                     MemberModel.State.joined.rawValue.uppercased()],
                                             "change_state_getinfo_members":
                                                MemberModel.State.joined.rawValue.uppercased()],
                                   "timestamp_state": ["getinfo_setinfo_delete_conversation":
                                    [MemberModel.State.invited.rawValue,
                                     MemberModel.State.joined.rawValue],
                                                       "change_state_getinfo_members":
                                                        MemberModel.State.joined.rawValue],
                                   "userid_joined": TestConstants.User.uuid,
                                   "memberid_joined": TestConstants.Member.uuid,
                                   "username_joined": TestConstants.User.name,
                                   "wait": ["session:success": "4"]].JSONString else { return fail() }
                
                var joinedMember: Member?
                var conversationJoined: Conversation?
                
                _ = self.client.conversation.conversations.asObservable.subscribe(onNext: { change in
                    switch change {
                    case .inserted(let conversation, let reason):
                        switch reason {
                        case .modified: conversationJoined = conversation
                        default: break
                        }
                    default: break
                    }
                })
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                // before receiving member:joined
                expect(conversation).toEventuallyNot(beNil())
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                
                conversation.memberJoined.addHandler { member in
                    joinedMember = member
                }
                
                // after receiving member:joined
                expect(joinedMember).toEventuallyNot(beNil())
                expect(joinedMember?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(joinedMember?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(joinedMember?.user.name).toEventually(equal(TestConstants.User.name))
                expect(joinedMember?.state).toEventually(equal(.joined))
                
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                
                expect(conversationJoined?.uuid).toEventually(equal(TestConstants.Conversation.uuid))
                expect(conversationJoined?.name).toEventually(equal(TestConstants.Conversation.name))
                expect(conversationJoined?.state).toEventually(equal(.joined))
                expect(conversationJoined?.members.count).toEventually(equal(2))
            }
        }
    }
}
