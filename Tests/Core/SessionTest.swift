//
//  SessionTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class SessionTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("creates a session model") {
            let json = self.json(path: .sessionSuccess)
            let model = try? JSONDecoder().decode(Session.self, from: json)
            
            expect(model?.id.isEmpty) == false
        }
        
        it("fails to create a session model") {
            let model = try? JSONDecoder().decode(Session.self, from: [:])
            
            expect(model).to(beNil())
        }
    }
}
