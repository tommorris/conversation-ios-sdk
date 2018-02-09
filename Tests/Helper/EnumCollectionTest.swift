//
//  EnumCollectionTest.swift
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

internal class EnumCollectionTest: QuickSpec {
    
    private enum ConformingEnum: String, EnumCollection {
        case one = "One", two = "Two"
    }

    // MARK:
    // MARK: Test
    
    override func spec() {
        it("returns an array of all case values as a property called allValues") {
            let allValues = ConformingEnum.allValues
            
            expect(allValues.count) == 2
        }
    }
}
