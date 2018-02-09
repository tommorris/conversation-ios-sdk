//
//  E2EDefaultSetup.swift
//  NexmoConversation
//
//  Created by Ashley Arthur on 27/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import NexmoConversation

class E2EDefaultTestSetup: QuickConfiguration {
    
    override class func configure(_ configuration: Quick.Configuration) {
        configuration.beforeSuite {
            Nimble.AsyncDefaults.Timeout = 10
            Nimble.AsyncDefaults.PollInterval = 1
        }
        
        configuration.beforeSuite {
            guard let userData = try? Mock.setup() else {
                fatalError("Precondition Failed: Unable to create Users")
            }
            configuration.afterSuite {
                userData.remove()
            }
        }
        
        // Login into Client
        configuration.beforeSuite {
            // for now we do this ONCE per test s as login/logout is flakey
            do {
                guard Mock.user != Mock.placeholderUser else {
                    fatalError("Precondition Failed: No User Created for Login")
                }
                let token = try E2ETestCSClient.token(for: Mock.user.name)
                do {
                    ConversationClient.instance.login(with: token, { if $0 != .success { fail() } })
                    _ = try ConversationClient.instance.state.asObservable().filter{$0 == .synchronized}.toBlocking(timeout:15).first()
                }
                catch {
                    fatalError("Failed to login with client") // Not much point continuing
                }
            }
            catch {
                fatalError("Failed to create login token for user") // Not much point continuing
            }

        }
        
        configuration.afterSuite {
            BasicOperations.logout(client: ConversationClient.instance)
        }
        
        configuration.afterEach {
            do {
                try E2ETestCSClient.deleteUserConversations(for: Mock.user.uuid, with: nil)
            }
            catch {
                print("Warning: Unable to clean up conversations for suite \(self.description)")
            }
        }
    }
}
