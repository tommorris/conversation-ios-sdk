//
//  SyncTest.swift
//  NexmoConversation
//
//  Created by Ivan on 22/05/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class SyncTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    let client = ConversationClient.instance
    
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 5
        Nimble.AsyncDefaults.PollInterval = 1
        
        afterEach {
            BasicOperations.logout(client: self.client)
        }
        
        context("sync") {
            
            it("state should change to synchronized after login") {
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
                
                self.client.login(with: "token") { guard $0 == .success else { return fail() } }

                expect(self.client.state.value).toEventually(equal(ConversationClient.State.synchronized))
            }
            
            it("state should stay disconnected on login error") {
                guard let token = ["template": "system_error_invalid-token"].JSONString else { return fail() }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
                
                self.client.login(with: token) { guard $0 == .success else { return fail() } }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
            }
            
            it("state should change to synchronized and then to disconnected after logout") {
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
                
                self.client.login(with: "token") { guard $0 == .success else { return fail() } }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.synchronized))
                
                BasicOperations.logout(client: self.client)
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
            }
            
            it("state should change to synchronized and then to disconnected on error after login") {
                guard let token = ["template": "default,system_error_invalid-token", "wait": "5"].JSONString else { return fail() }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
                
                self.client.login(with: token) { guard $0 == .success else { return fail() } }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.synchronized))
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
            }
            
            it("state should change to connecting and then to synchronized on slow connection") {
                guard let token = ["template": "ses-success", "wait": 3].JSONString else { return fail() }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.disconnected))
                
                self.client.login(with: token) { guard $0 == .success else { return fail() } }
                
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.connecting))
                expect(self.client.state.value).toEventually(equal(ConversationClient.State.synchronized))
            }
        }
    }
}
