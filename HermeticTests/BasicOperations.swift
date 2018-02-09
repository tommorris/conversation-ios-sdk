//
//  BasicOperations.swift
//  NexmoConversation
//
//  Created by Ivan on 18/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import NexmoConversation
import Nimble
import RxSwift
import RxTest
import RxBlocking

/// Helper class containing functions used in various tests
struct BasicOperations {

    // MARK:
    // MARK: Account
    
    /// Login user
    ///
    /// - Parameters:
    ///   - with client: ConversationClient object
    ///   - using token: token used
    static func login(with client: ConversationClient, using token: String="session_token", waitForSync: Bool=true) {
        // login
        client.login(with: token, { if $0 != .success { fail() } })
        
        expect(client.account.state.value).toEventuallyNot(equal(AccountController.State.loggedOut))

        let isSynchronized: () -> Bool = { client.state.value == .synchronized }

        if waitForSync {
            expect(isSynchronized()).toEventually(beTrue(), timeout: 15, pollInterval: 1)
        }
    }
    
    /// Logout user
    ///
    /// - Parameter client: ConversationClient object
    static func logout(client: ConversationClient) {
        guard case .loggedIn(_) = client.account.state.value else { return }
        
        client.logout()
        
        expect(client.account.state.value).toEventually(
            equal(AccountController.State.loggedOut),
            timeout: 5,
            pollInterval: 1
        )
    }
}
