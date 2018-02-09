//
//  EventStateTest.swift
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

internal class EventStateTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Test
        
        it("creates a model") {
            let json = self.json(path: .eventState)
            let model = try? JSONDecoder().decode(EventState.self, from: json)
            
            expect(model).toNot(beNil())
            expect(model?.deliveredTo).toNot(beNil())
            expect(model?.seenBy).toNot(beNil())
        }
        
        it("fails to create a model") {
            expect(try? JSONDecoder().decode(EventState.self, from: [:])).to(beNil())
        }
    }
}
