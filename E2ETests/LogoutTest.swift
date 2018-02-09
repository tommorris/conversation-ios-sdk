//
//  LogoutTest.swift
//  NexmoConversationE2ETests
//
//  Created by Ivan on 05/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class LogoutTest: QuickSpec {
    let client = ConversationClient.instance
    var token: String = ""
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        beforeEach {
            do {
                self.token = try E2ETestCSClient.token(for: Mock.user.name)
            }
            catch {
                return fail("Error: Unable to create user token for suite \(self.description)")
            }
        }
        
        afterEach {
            BasicOperations.logout(client: self.client)
        }
        
        xit("user can log out") {
            BasicOperations.login(with: self.client, using: self.token, waitForSync: false)
            
            expect(self.client.account.state.value).toEventuallyNot(equal(AccountController.State.loggedOut))
            
            self.client.logout()
            
            expect(self.client.account.state.value).toEventually(equal(AccountController.State.loggedOut))
        }
    }
}
