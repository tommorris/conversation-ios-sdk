//
//  EventBodyRTCTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 09/11/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import NexmoConversation

internal class EventBodyRTCTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Audio Test
        
        it("creates a audio enabled model") {
            do {
                let json = self.json(path: .audioEnabled)
                let event = try Event(json: json)
                let audio: Event.Body.Audio? = try event.model()
                
                expect(audio).toNot(beNil())
                expect(audio?.enabled).to(beTrue())
            } catch {
                fail()
            }
        }
        
        it("fails to creates a audio enabled model") {
            expect { _ = try JSONDecoder().decode(Event.Body.Audio.self, from: [:]) }.to(throwError())
        }
    }
}
        
