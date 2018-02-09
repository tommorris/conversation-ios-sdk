//
//  AllModelsTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 29/11/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class PushNotificationCertificateTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("push certificate fails to create model") {
            let decoder = JSONDecoder()
            let model = try? decoder.decode(PushNotificationCertificate.self, from: [:])
            
            expect(model).to(beNil())
        }
        
        it("push certificate creates model") {
            let decoder = JSONDecoder()
            let model = try? decoder.decode(PushNotificationCertificate.self, from: ["token":"token", "password": "password"])
            
            expect(model).toNot(beNil())
            expect(model?.certificate.isEmpty).to(beFalse())
            expect(model?.password?.isEmpty).to(beFalse())
        }
        
        it("push certificate creates model with no password") {
            let decoder = JSONDecoder()
            let model = try? decoder.decode(PushNotificationCertificate.self, from: ["token":"token"])
            
            expect(model).toNot(beNil())
            expect(model?.certificate.isEmpty).to(beFalse())
            expect(model?.password).to(beNil())
        }
    }
}
