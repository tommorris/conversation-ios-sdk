//
//  DecoderHelperTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class DecoderHelperTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("creates a date from a string") {
            let date: Date? = DateFormatter.ISO8601?.date(from: "2017-01-01T09:27:14.875Z")
            
            expect(date).toNot(beNil())
        }
    }
}
