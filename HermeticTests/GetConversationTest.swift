//
//  GetConversationTest.swift
//  NexmoConversation
//
//  Created by Ivan on 20/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class GetConversationTest: QuickSpec {
    
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
        
        describe("Conversation Preview") {
            beforeEach {
                guard let token = ["template": ["session:success": "default",
                                                "send_getrange_events": "event-list-empty"]].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
            }
            
            describe("Obj C Interface") {
                let preview = { () -> [String:String]? in
                    var preview: [String:String]?
                    
                    waitUntil(timeout:Nimble.AsyncDefaults.Timeout) { done in
                        self.client.conversation.all({ (conversations:[[String:String]]) -> () in
                            preview = conversations.first
                            done()
                        }, onFailure: { _ in
                            fail()
                        })
                    }
                    return preview
                }
                
                it("has a name") {
                    guard let p = preview(), let name = p["name"] else { return fail() }
                    
                    expect(name).to(equal(TestConstants.Conversation.name))
                }
                
                it("has a uuid") {
                    guard let p = preview() else { return fail() }
                    
                    expect(p["uuid"]).to(equal(TestConstants.Conversation.uuid))
                }
            }
            
            describe("Swift Interface") {
                let preview = { () -> ConversationController.LiteConversation? in
                    guard let previews = try? self.client.conversation.all().toBlocking(timeout: Nimble.AsyncDefaults.Timeout).first() else { return nil }
                    return previews?.first
                }
                
                it("has a name") {
                    guard let p = preview() else { return fail() }
                    
                    expect(p.name).to(equal(TestConstants.Conversation.name))
                }
                
                it("has a uuid") {
                    guard let p = preview() else { return fail() }
                    
                    expect(p.uuid).to(equal(TestConstants.Conversation.uuid))
                }
            }
        }

        context("get conversation details") {
            it("should pass") {
                BasicOperations.login(with: self.client)
                
                var conversationResponse: Conversation?
                
                _ = self.client.conversation.conversation(with: TestConstants.Conversation.uuid).subscribe(onNext: { conversation in
                    conversationResponse = conversation
                }, onError: { _ in
                    fail()
                })
                
                expect(conversationResponse?.name).toEventually(equal(TestConstants.Conversation.uuid))
            }

            it("should fail when user is not logged in") {
                var responseError: Error?
                
                self.client.addAuthorization(with: "")
                _ = self.client.conversation.conversation(with: TestConstants.Conversation.uuid).subscribe(onError: { error in
                    responseError = error
                })
                
                expect(responseError).toEventuallyNot(beNil())
            }
            
            it("should fail when malformed JSON is returned by server") {
                let token = TokenBuilder(response: .getInfoSetInfoDeleteConversation).get.build

                BasicOperations.login(with: self.client, using: token, waitForSync: false)

                expect {
                    try self.client.conversation.conversation(with: TestConstants.Conversation.uuid).toBlocking().first()
                }.to(throwError())

                expect(self.client.state.value) == ConversationClient.State.outOfSync
            }
            
            it("members should be retrieved with the conversation") {
                BasicOperations.login(with: self.client)
                
                var conversation: Conversation?

                do {
                    conversation = try self.client.conversation.conversation(with: TestConstants.Conversation.uuid)
                        .toBlocking()
                        .first()
                } catch let error {
                    fail(error.localizedDescription)
                }

                expect(conversation?.members).toEventuallyNot(beNil())
                expect(conversation?.members.count).toEventuallyNot(equal(0))
            }
            
            it("should pass on sync for a conversation in joined state") {
                BasicOperations.login(with: self.client)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .joined }).count).toEventually(equal(2))
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.creationDate).toEventuallyNot(beNil())
                expect(conversation.lastSequence).toEventually(equal(3))
                expect(conversation.users.count).toEventually(equal(2))
                
                expect(conversation.members.first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.first?.user.name).toEventually(equal(TestConstants.User.name))
                expect(conversation.members.first?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(conversation.members.first?.user.isMe).toEventually(beTrue())
                
                expect(conversation.members[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(conversation.members[1].state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members[1].user.name).toEventually(equal(TestConstants.PeerUser.name))
                expect(conversation.members[1].user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(conversation.members[1].user.isMe).toEventually(beFalse())
            }
            
            it("should pass on sync for a conversation in invited state") {
                guard let token = ["state": MemberModel.State.invited.rawValue.uppercased()].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .invited }).count).toEventually(equal(2))
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.creationDate).toEventuallyNot(beNil())
                expect(conversation.lastSequence).toEventually(equal(3))
                expect(conversation.users.count).toEventually(equal(2))
                
                expect(conversation.members.first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.members.first?.user.name).toEventually(equal(TestConstants.User.name))
                expect(conversation.members.first?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(conversation.members.first?.user.isMe).toEventually(beTrue())
                
                expect(conversation.members[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(conversation.members[1].state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.members[1].user.name).toEventually(equal(TestConstants.PeerUser.name))
                expect(conversation.members[1].user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(conversation.members[1].user.isMe).toEventually(beFalse())
            }
            
            it("should pass on sync for a conversation in left state") {
                guard let token = ["state": MemberModel.State.left.rawValue.uppercased()].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.members.count).toEventually(equal(2))
                expect(conversation.members.filter({ $0.state == .left }).count).toEventually(equal(2))
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.creationDate).toEventuallyNot(beNil())
                expect(conversation.lastSequence).toEventually(equal(3))
                expect(conversation.users.count).toEventually(equal(2))
                
                expect(conversation.members.first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members.first?.user.name).toEventually(equal(TestConstants.User.name))
                expect(conversation.members.first?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(conversation.members.first?.user.isMe).toEventually(beTrue())
                
                expect(conversation.members[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(conversation.members[1].state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members[1].user.name).toEventually(equal(TestConstants.PeerUser.name))
                expect(conversation.members[1].user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(conversation.members[1].user.isMe).toEventually(beFalse())
            }
            
            it("should pass on sync for a conversation with a single member") {
                guard let token = ["template": ["getinfo_setinfo_delete_conversation": "conversation-single-member",
                                                "send_getrange_events": "event-list-empty"]].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.members.count).toEventually(equal(1))
                expect(conversation.members.filter({ $0.state == .joined }).count).toEventually(equal(2))
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.creationDate).toEventuallyNot(beNil())
                expect(conversation.lastSequence).toEventually(equal(3))
                expect(conversation.users.count).toEventually(equal(1))
                
                expect(conversation.members.first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.first?.user.name).toEventually(equal(TestConstants.User.name))
                expect(conversation.members.first?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                expect(conversation.members.first?.user.isMe).toEventually(beTrue())
            }
            
            pending("should pass on sync for multiple conversations with same member id") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-multi",
                                                "send_getrange_events": "event-list-empty"]].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(3))
                
                self.client.conversation.conversations.forEach { conversation in
                    expect(conversation.members.count).toEventually(equal(2))
                    expect(conversation.members.filter({ $0.state == .joined }).count).toEventually(equal(2))
                    expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                    expect(conversation.creationDate).toEventuallyNot(beNil())
                    expect(conversation.lastSequence).toEventually(equal(3))
                    expect(conversation.users.count).toEventually(equal(2))
                    
                    expect(conversation.members.first?.uuid).toEventually(equal(TestConstants.Member.uuid))
                    expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.joined))
                    expect(conversation.members.first?.user.name).toEventually(equal(TestConstants.User.name))
                    expect(conversation.members.first?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                    expect(conversation.members.first?.user.isMe).toEventually(beTrue())
                    
                    expect(conversation.members[1].uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                    expect(conversation.members[1].state).toEventually(equal(MemberModel.State.joined))
                    expect(conversation.members[1].user.name).toEventually(equal(TestConstants.PeerUser.name))
                    expect(conversation.members[1].user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                    expect(conversation.members[1].user.isMe).toEventually(beFalse())
                }
            }
            
            it("should pass on sync for multiple conversations with different member id") {
                guard let token = ["template": ["get_user_conversation_list": "conversation-list-multi",
                                                "send_getrange_events": "event-list-empty",
                                                "getinfo_setinfo_delete_conversation": "conversation-random-member"]].JSONString else {
                    return fail()
                }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(3))
                
                self.client.conversation.conversations.forEach { conversation in
                    expect(conversation.members.count).toEventually(equal(1))
                    expect(conversation.members.filter({ $0.state == .joined }).count).toEventually(equal(1))
                    expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                    expect(conversation.creationDate).toEventuallyNot(beNil())
                    expect(conversation.lastSequence).toEventually(equal(3))
                    expect(conversation.users.count).toEventually(equal(1))
                    
                    expect(conversation.members.first?.uuid).toEventually(beginWith("MEM-"))
                    expect(conversation.members.first?.state).toEventually(equal(MemberModel.State.joined))
                    expect(conversation.members.first?.user.name).toEventually(equal(TestConstants.User.name))
                    expect(conversation.members.first?.user.uuid).toEventually(equal(TestConstants.User.uuid))
                    expect(conversation.members.first?.user.isMe).toEventually(beTrue())
                }
            }
            
            it("invited_by field should be exposed for conversation in invited state") {
                guard let token = ["template": "conversation-invitedby",
                                   "by_user_name": TestConstants.PeerUser.name,
                                   "state": MemberModel.State.invited.rawValue.uppercased(),
                                   "timestamp_state": MemberModel.State.invited.rawValue].JSONString else { return fail() }
                
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
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))
                expect(conversation.members.first?.invitedBy).toEventuallyNot(beNil())
                expect(conversation.members.first?.invitedBy?.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(conversation.members.first?.invitedBy?.state).toEventually(equal(.invited))
                expect(conversation.members.first?.invitedBy?.user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(conversation.members.first?.invitedBy?.user.name).toEventually(equal(TestConstants.PeerUser.name))
            }
            
            it("invited_by field should be exposed for conversation in joined state") {
                guard let token = ["template": "conversation-invitedby",
                                   "by_user_name": TestConstants.PeerUser.name,
                                   "state": MemberModel.State.joined.rawValue.uppercased(),
                                   "timestamp_state": MemberModel.State.joined.rawValue].JSONString else { return fail() }

                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                expect(conversation.members.first?.invitedBy).toEventuallyNot(beNil())
                expect(conversation.members.first?.invitedBy?.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(conversation.members.first?.invitedBy?.state).toEventually(equal(.joined))
                expect(conversation.members.first?.invitedBy?.user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(conversation.members.first?.invitedBy?.user.name).toEventually(equal(TestConstants.PeerUser.name))
            }
            
            it("invited_by field should be exposed for conversation in left state") {
                guard let token = ["template": "conversation-invitedby",
                                   "by_user_name": TestConstants.PeerUser.name,
                                   "state": MemberModel.State.left.rawValue.uppercased(),
                                   "timestamp_state": MemberModel.State.left.rawValue].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                expect(conversation.members.first?.invitedBy).toEventuallyNot(beNil())
                expect(conversation.members.first?.invitedBy?.uuid).toEventually(equal(TestConstants.PeerMember.uuid))
                expect(conversation.members.first?.invitedBy?.state).toEventually(equal(.left))
                expect(conversation.members.first?.invitedBy?.user.uuid).toEventually(equal(TestConstants.PeerUser.uuid))
                expect(conversation.members.first?.invitedBy?.user.name).toEventually(equal(TestConstants.PeerUser.name))
            }
            
            it("should add date timestamps to member for invited state") {
                guard let token = ["template": "conversation-invitedby",
                                   "by_user_name": TestConstants.PeerUser.name,
                                   "state": MemberModel.State.invited.rawValue.uppercased(),
                                   "timestamp_state": MemberModel.State.invited.rawValue].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.invited))

                expect(conversation.members.first?.date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventually(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.left)).toEventually(beNil())
                
                expect(conversation.members[1].date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventually(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.left)).toEventually(beNil())
            }
            
            it("should add date timestamps to member for joined state") {
                BasicOperations.login(with: self.client)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))
                
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.invited)).toEventually(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.left)).toEventually(beNil())
                
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.invited)).toEventually(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.left)).toEventually(beNil())
            }
            
            it("should add date timestamps to member for left state") {
                guard let token = ["state": MemberModel.State.left.rawValue.uppercased(),
                                   "timestamp_state": MemberModel.State.left.rawValue].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.left))
                
                expect(conversation.members.first?.date(of: MemberModel.State.left)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.invited)).toEventually(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventually(beNil())
                
                expect(conversation.members[1].date(of: MemberModel.State.left)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventually(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventually(beNil())
            }
            
            it("should add date timestamps to member for all states") {
                guard let token = ["template": "conversation-all-states",
                                   "by_user_name": TestConstants.PeerUser.name].JSONString else { return fail() }
                
                BasicOperations.login(with: self.client, using: token)
                
                expect(self.client.conversation.conversations.count).toEventually(equal(1))
                guard let conversation = self.client.conversation.conversations.first else { return fail() }
                
                expect(conversation.state).toEventually(equal(MemberModel.State.joined))

                expect(conversation.members.first?.date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members.first?.date(of: MemberModel.State.left)).toEventuallyNot(beNil())
                
                expect(conversation.members[1].date(of: MemberModel.State.invited)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.joined)).toEventuallyNot(beNil())
                expect(conversation.members[1].date(of: MemberModel.State.left)).toEventuallyNot(beNil())
            }
        }
    }
}
