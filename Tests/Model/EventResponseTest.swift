//
//  EventResponseTest.swift
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

internal class EventResponseTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Test
        
        it("create event model") {
            let json = self.json(path: .sendImageMessage)
            guard let model = try? JSONDecoder().decode(EventResponse.self, from: json) else { return fail() }
            
            expect(model).toNot(beNil())
            expect(Int(model.id)).to(beGreaterThan(1))
        }
        
        it("fail creating event model") {
            let model = try? JSONDecoder().decode(EventResponse.self, from: [:])
            
            expect(model).to(beNil())
        }
        
        it("fail creating event model href") {
            let model = try? JSONDecoder().decode(EventResponse.self, from: ["id": 123])
            
            expect(model).to(beNil())
        }
        
        it("fail creating event model href") {
            let model = try? JSONDecoder().decode(EventResponse.self, from: [
                "id": 123,
                "href": "http://example.com"
            ])
            
            expect(model).to(beNil())
        }
        
        it("creating event model date") {
            let model = try? JSONDecoder().decode(EventResponse.self, from: [
                "id": 123,
                "href": "http://example.com",
                "timestamp": "2016-10-03T09:27:14.875Z"
            ])
            
            expect(model).toNot(beNil())
        }
    }
}
