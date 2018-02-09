//
//  UserTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class UserTest: QuickSpec, E2ECSClientSpec {
    override func spec() {
        standardSetup()
        
        it("user can retrieve details about own user") {
            var responseUser: User?
            
            self.client.account.user(with: Mock.user.uuid, { user in
                responseUser = user
            }, onFailure: { error in
                fail()
            })
            
            expect(responseUser).toEventuallyNot(beNil())
            expect(responseUser?.isMe).toEventually(beTrue())
            expect(responseUser?.uuid).toEventually(equal(Mock.user.uuid))
            expect(responseUser?.name).toEventually(equal(Mock.user.name))
        }
        
        it("user can retrieve details about another user") {
            var responseUser: User?
            
            self.client.account.user(with: Mock.peerUser.uuid, { user in
                responseUser = user
            }, onFailure: { error in
                fail()
            })
            
            expect(responseUser).toEventuallyNot(beNil())
            expect(responseUser?.isMe).toEventually(beFalse())
            expect(responseUser?.uuid).toEventually(equal(Mock.peerUser.uuid))
            expect(responseUser?.name).toEventually(equal(Mock.peerUser.name))
        }
    }
}
