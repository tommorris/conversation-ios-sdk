//
//  StorageTest.swift
//  NexmoConversation
//
//  Created by shams ahmed on 14/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxTest
import RxBlocking
@testable import NexmoConversation

internal class StorageTest: QuickSpec {
    
    let storage: Storage = {
        let network = NetworkController(token: "token")
        let account = AccountController(network: network)
        let conversation = ConversationController(network: network, account: account, rtc: RTCController(network: network))
        let membership = MembershipController(network: network)
        
        let storage = Storage(account: account, conversation: conversation, membershipController: membership)
        
        let event = EventController(network: network, storage: storage)
        let queue = EventQueue(storage: storage, event: event)
        
        storage.eventQueue = queue
        storage.eventController = event
        
        return storage
    }()
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Test
        
        it("resets all cache data") {
            expect { try self.storage.reset() }.toNot(throwAssertion())
            expect(self.storage.fileCache.contents.isEmpty) == true
        }
    }
}
