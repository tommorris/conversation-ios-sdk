//
//  AccountControllerTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 28/10/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxBlocking
@testable import NexmoConversation

internal class AccountControllerTest: QuickSpec {
    
    let mock = SimpleMockDatabase()
    
    let account = AccountController(network: NetworkController(token: "token"))
    
    let databaseManager = DatabaseManager()
    
    let network = NetworkController(token: "token")
    
    lazy var eventController: EventController = {
        let storage = Storage(account: self.account,
                              conversation: ConversationController(network: self.network, account: self.account, rtc: RTCController(network: self.network)),
                              membershipController: MembershipController(network: self.network)
        )

        let event = EventController(
            network: self.network,
            storage: storage
        )

        storage.eventController = event 

        return event
    }()
    
    lazy var event: EventQueue = {
       return EventQueue(storage: self.cache, event: self.eventController)
    }()
    
    lazy var cache: Storage = {
        let conversationController = ConversationController(network: self.network, account: self.account, rtc: RTCController(network: self.network))
        
        let cache = Storage(
            account: self.account,
            conversation: conversationController,
            membershipController: MembershipController(network: self.network)
        )

        cache.eventController = self.eventController
        
        return cache
    }()
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        cache.eventQueue = event
        account.storage = cache
    }
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        beforeEach {
            self.setup()
        }
        
        // MARK:
        // MARK: Login
        
        it("checks user is not loggedin") {
            self.account.state.value = .loggedOut
            
            expect(self.account.state.value == .loggedOut) == true
        }
        
        it("checks user is not loggedin using observable") {
            var newState: AccountController.State?
            
            _ = self.account.state.asObservable().subscribe(onNext: { state in
                newState = state
            })
            
            self.account.state.value = .loggedOut
            
            expect(newState).toEventually(equal(AccountController.State.loggedOut))
        }
        
        it("checks user is loggedin using observable") {
            var newState: AccountController.State?
            
            _ = self.account.state.asObservable().subscribe(onNext: { state in
                newState = state
            })
            
            let session = Session(id: "1", userId: "usr-123", name: "user 1")
            
            self.account.state.value = .loggedIn(session)
            
            expect(newState).toEventually(equal(AccountController.State.loggedIn(session)))
        }
        
        // MARK:
        // MARK: User
        
        it("fetches user") {
            self.stub(file: .demo1, request: AccountRouter.user(id: "usr-123").urlRequest)
            
            guard let user = try? self.account.user(with: "usr-123").toBlocking().first() else { return fail() }
            
            expect(user?.uuid).toNot(beNil())
            expect(user?.displayName.isEmpty) == false
        }
        
        it("fails to fetch a specfic user") {
            self.stubServerError(request: AccountRouter.user(id: "usr-123").urlRequest)
            
            let user = try? self.account.user(with: "usr-123")
                .toBlocking()
                .first()
            
            expect(user).to(beNil())
        }
        
        it("fails to fetch a specfic user with no json data") {
            self.stub(json: [:], request: AccountRouter.user(id: "usr-123").urlRequest)
            
            let user = try? self.account.user(with: "usr-123")
                .toBlocking()
                .first()
            
            expect(user).to(beNil())
        }
        
        it("updates the keychain with new token") {
            self.account.token = "token-123"
            
            expect(self.account.token) == "token-123"
        }

        it("remove the token keychain with nil") {
            self.account.token = nil
            
            expect(self.account.token).toEventually(beNil(), timeout: 5)
        }
        
        it("valdiates equal for state match up") {
            let session = Session(id: "1", userId: "usr-123", name: "test")
            
            expect(AccountController.State.loggedOut) == AccountController.State.loggedOut
            expect(AccountController.State.loggedIn(session)) == AccountController.State.loggedIn(session)
            expect(AccountController.State.loggedIn(session)) != AccountController.State.loggedOut
        }
        
        it("fetches the current user") {
            expect { try self.databaseManager.user.insert(self.mock.user1) }.toNot(throwAssertion())
            
            self.account.userId = self.mock.user1.rest.uuid
            
            expect(self.account.user).toNot(beNil())
        }
        
        it("fails to fetch the current user") {
            self.account.userId = ""
            self.account.state.value = .loggedOut
            
            expect(self.account.user).to(beNil())
        }
    }
}
