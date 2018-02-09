//
//  RTCTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 01/12/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxTest
import RxBlocking
@testable import NexmoConversation

internal class RTCTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("fails to create response model") {
            let response = try? JSONDecoder().decode(RTC.Response.self, from: [:])
            
            expect(response).to(beNil())
        }
        
        it("creates response model") {
            let response = try? JSONDecoder().decode(RTC.Response.self, from: ["rtc_id": "id"])
            
            expect(response?.id).to(equal("id"))
            expect(response).toNot(beNil())
        }
        
        it("fails to create answer model") {
            expect(try? JSONDecoder().decode(RTC.Answer.self, from: [:])).to(beNil())
            expect(try? JSONDecoder().decode(RTC.Answer.self, from: ["body": ["answer": "sdp"]])).to(beNil())
            expect(try? JSONDecoder().decode(RTC.Answer.self, from: [
                "body": [
                    "answer": "sdp",
                    "rtc_id": "id"
                ]
            ])).to(beNil())
            
            expect(try? JSONDecoder().decode(RTC.Answer.self, from: [
                "cid": "con-123",
                "body": [
                    "answer": "sdp",
                    "rtc_id": "id"
                ]
                ])).to(beNil())
        }
    }
}
