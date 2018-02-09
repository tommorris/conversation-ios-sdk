//
//  RawDataTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 30/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class RawDataTest: QuickSpec {

    // MARK:
    // MARK: Test

    override func spec() {
        it("creates a new model") {
            let model = RawData(Data())

            expect(model).toNot(beNil())
            expect(model.value).toNot(beNil())
        }
    }
}
