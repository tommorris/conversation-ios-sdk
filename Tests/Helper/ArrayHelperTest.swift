//
//  ArrayHelperTest.swift
//  NexmoConversation
//
//  Created by paul calver on 25/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class ArrayHelperTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("returns nil if indexpath out of range") {
            let array: [Int] = []
            let element = array[safe: 1]
            
            expect(element).to(beNil())
        }
        
        it("return element if indexpath in range") {
            let array = ["1", "2"]
            let element = array[safe: 1]
            
            expect(element) == "2"
        }
    }
}
