//
//  BoolTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 31/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class BoolTest: QuickSpec {

    // MARK:
    // MARK: Test

    override func spec() {
        it("converts true string bool to Bool object") {
            expect(Bool(string: "true")) == true
            expect(Bool(string: "yes")) == true
            expect(Bool(string: "1")) == true
            expect(Bool(string: "TRUE")) == true
        }

        it("converts false string bool to Bool object") {
            expect(Bool(string: "false")) == false
            expect(Bool(string: "no")) == false
            expect(Bool(string: "0")) == false
            expect(Bool(string: "FALSE")) == false
        }

        it("fails to converts string bool to Bool object") {
            expect(Bool(string: "maybe")).to(beNil())
        }

        it("fails to converts empty string to Bool object") {
            expect(Bool(string: nil)).to(beNil())
        }

        it("fails to converts random string to Bool object") {
            expect(Bool(string: "nexmo")).to(beNil())
        }
    }
}
