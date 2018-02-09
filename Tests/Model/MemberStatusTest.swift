//
//  MemberStatusTest.swift
//  NexmoConversation
//
//  Created by shams ahmed on 07/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class MemberStatusTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Test
        
        it("create a member status model") {
            let json = self.json(path: .joinConversation)
            guard let model = try? JSONDecoder().decode(MemberStatus.self, from: json) else { return fail() }
            
            expect(model.memberId).toNot(beNil())
            expect(model.state) == MemberModel.State.joined
        }
        
        it("fail creating status model") {
            let model = try? JSONDecoder().decode(MemberStatus.self, from: [:])
            
            expect(model).to(beNil())
        }
        
        it("fail creating status model with only state") {
            let model = try? JSONDecoder().decode(MemberStatus.self, from: ["state": ""])
            
            expect(model).to(beNil())
        }
        
        it("fail creating status model with bad timr/date") {
            let model = try? JSONDecoder().decode(MemberStatus.self, from: [
                "id": "",
                "user_id": "",
                "state": "JOINED"
                ]
            )
            
            expect(model).to(beNil())
        }
        
        it("creating status model with bad channel data") {
            let model = try? JSONDecoder().decode(MemberStatus.self, from: [
                "id": "",
                "user_id": "",
                "state": "JOINED",
                "timestamp": ["joined": "2016-12-06T16:55:27.273Z"]
                ]
            )
            
            expect(model).toNot(beNil())
        }
    }
}
