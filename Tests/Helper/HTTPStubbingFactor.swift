//
//  HTTPStubbingFactor.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 31/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay
@testable import NexmoConversation

/// Helper for Objective-C test cases
@objc
@objcMembers
public class HTTPStubbingFactor: NSObject {

    // MARK:
    // MARK: Conversations

    static func detailedConversations(with test: XCTestCase, for uuid: String) {
        test.stub(file: .fullConversation, request: ConversationRouter.conversation(id: uuid).urlRequest)
    }

    static func fetchsAllConversations(with test: XCTestCase, from index: Int) {
        test.stub(file: .allWithoutUserId1, request: ConversationRouter.all(from: index).urlRequest)
        test.stub(file: .allWithoutUserId2, request: ConversationRouter.all(from: 100).urlRequest)
        test.stub(file: .allWithoutUserId3, request: ConversationRouter.all(from: 200).urlRequest)
        test.stub(file: .allWithoutUserId4, request: ConversationRouter.all(from: 300).urlRequest)
        test.stub(file: .allWithoutUserId5, request: ConversationRouter.all(from: 400).urlRequest)
        test.stub(file: .allWithoutUserId6, request: ConversationRouter.all(from: 499).urlRequest)
        test.stub(file: .allWithoutUserId7, request: ConversationRouter.all(from: 597).urlRequest)
        test.stub(file: .allWithoutUserId8, request: ConversationRouter.all(from: 696).urlRequest)
        test.stub(file: .allWithoutUserId9, request: ConversationRouter.all(from: 792).urlRequest)
        test.stub(file: .allWithoutUserId10, request: ConversationRouter.all(from: 793).urlRequest)
        test.stub(file: .allWithoutUserId10, request: ConversationRouter.all(from: 836).urlRequest)
    }

    static func fetchsAllConversationsError(with test: XCTestCase, from index: Int) {
        test.stubClientError(request: ConversationRouter.all(from: index).urlRequest)
    }
    
    static func fetchsAllConversations(with test: XCTestCase, forUserId userId: String) {
        test.stub(file: .conversations, request: ConversationRouter.allUser(id: userId).urlRequest)
    }
    
    static func fetchsAllConversationsError(with test: XCTestCase, forUserId userId: String) {
        test.stubClientError(request: ConversationRouter.allUser(id: userId).urlRequest)
    }
    
    // MARK:
    // MARK: Conversation
    
    static func conversation(with test: XCTestCase, forId id: String) {
        test.stub(file: .fullConversation, request: ConversationRouter.conversation(id: id).urlRequest)
    }

    static func conversationError(with test: XCTestCase, forId id: String) {
        test.stubClientError(request: ConversationRouter.conversation(id: id).urlRequest)
    }
    
    // MARK:
    // MARK: Join
    
    static func join(with test: XCTestCase, uuid: String) {
        test.stub(file: .joinConversation, request: ConversationRouter.join(uuid: uuid, parameters: nil).urlRequest)
    }
    
    static func joinError(with test: XCTestCase, uuid: String) {
        test.stubClientError(request: ConversationRouter.join(uuid: uuid, parameters: nil).urlRequest)
    }
    
    // MARK:
    // MARK: Leave/Kick
    
    static func leave(with test: XCTestCase, inConversation uuid: String, forMember memberId: String) {
        test.stubOk(with: MembershipRouter.kick(conversationId: uuid, memberId: memberId).urlRequest)
    }
    
    static func leaveError(with test: XCTestCase, inConversation uuid: String, forMember memberId: String) {
        test.stubClientError(request: MembershipRouter.kick(conversationId: uuid, memberId: memberId).urlRequest)
    }
    
    static func kick(with test: XCTestCase, inConversation uuid: String, forMember memberId: String) {
        test.stubOk(with: MembershipRouter.kick(conversationId: uuid, memberId: memberId).urlRequest)
    }
    
    static func kickError(with test: XCTestCase, inConversation uuid: String, forMember memberId: String) {
        test.stubClientError(request: MembershipRouter.kick(conversationId: uuid, memberId: memberId).urlRequest)
    }
    
    // MARK:
    // MARK: Create

    static func create(with test: XCTestCase) {
        test.stub(file: .liteConversation, request: ConversationRouter.create(model: nil).urlRequest)
    }
    
    static func createError(with test: XCTestCase) {
        test.stubClientError(request: ConversationRouter.create(model: nil).urlRequest)
    }
    
    // MARK:
    // MARK: Event
    
    static func retrieve(with test: XCTestCase, forConversation uuid: String, start: Int, end: Int) {
        test.stub(file: .events, request: EventRouter.events(conversationUuid: uuid, range: Range<Int>(uncheckedBounds: (lower: start, upper: end))).urlRequest)
    }
    
    static func retrieveError(with test: XCTestCase, forConversation uuid: String, start: Int, end: Int) {
        test.stubClientError(request: EventRouter.events(conversationUuid: uuid, range: Range<Int>(uncheckedBounds: (lower: start, upper: end))).urlRequest)
    }
    
    // MARK:
    // MARK: User 
    
    static func user(with test: XCTestCase, forId id: String) {
        test.stub(file: .demo1, request: AccountRouter.user(id: id).urlRequest)
    }
    
    static func userError(with test: XCTestCase, forId id: String) {
        test.stubClientError(request: AccountRouter.user(id: id).urlRequest)
    }
    
    // MARK:
    // MARK: Member
    
    static func invite(with test: XCTestCase, forId id: String, inConversation conversationId: String) {
        test.stub(file: .inviteUser, request: MembershipRouter.invite(username: id, conversationId: conversationId).urlRequest)
    }
    
    static func inviteError(with test: XCTestCase, forId id: String, inConversation conversationId: String) {
        test.stubClientError(request: MembershipRouter.invite(username: id, conversationId: conversationId).urlRequest)
    }

    static func kick(with test: XCTestCase, forId id: String, fromConversation conversationId: String) {
        test.stubOk(with: MembershipRouter.kick(conversationId: conversationId, memberId: id).urlRequest)
    }
    
    static func kickError(with test: XCTestCase, forId id: String, fromConversation conversationId: String) {
        test.stubClientError(request: MembershipRouter.kick(conversationId: conversationId, memberId: id).urlRequest)
    }

    static func join(with test: XCTestCase, forConversation conversationId: String, userId: String, memberId: String?) {
        let join = ConversationController.JoinConversation(userId: userId, memberId: memberId)

        test.stub(file: .joinConversation, request: ConversationRouter.join(uuid: conversationId, parameters: join.json).urlRequest)
    }

    static func joinError(with test: XCTestCase, forConversation conversationId: String, userId: String, memberId: String?) {
        let join = ConversationController.JoinConversation(userId: userId, memberId: memberId)

        test.stubClientError(request: ConversationRouter.join(uuid: conversationId, parameters: join.json).urlRequest)
    }
}
