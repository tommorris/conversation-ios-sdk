//
//  NexmoConversationE2ETests.swift
//  NexmoConversationE2ETests
//
//  Created by Shams Ahmed on 13/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class LoginTest: QuickSpec {
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
        
        xit("user can log in") {
            var hasLoggedIn = false
            
            self.client.login(with: self.token, {
                if $0 != .success {
                    fail()
                }
                
                hasLoggedIn = true
            })
            
            expect(self.client.account.state.value).toEventuallyNot(equal(AccountController.State.loggedOut))
            expect(hasLoggedIn).toEventually(beTrue())
        }
    }
}
