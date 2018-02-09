//
//  KeyedDecodingContainerTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/01/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import NexmoConversation

internal class KeyedDecodingContainerTest: QuickSpec {
    
    struct Dummy: Decodable {
        
        enum Codingkeys: String, CodingKey {
            case date
        }
        
        let date: Date
        
        init(from decoder: Decoder) throws {
            date = try decoder.container(keyedBy: Codingkeys.self).decode(Date.self, forKey: .date)
        }
    }
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("creates model with proper date") {
            let plainText = "2017-02-10T17:29:51.237Z"
            var model: Dummy?
            
            expect { model = try JSONDecoder().decode(Dummy.self, from: ["date": plainText]) }.toNot(throwError())
            expect(model?.date).toNot(beNil())
        }
        
        it("fails to model with proper date") {
            expect { try JSONDecoder().decode(Dummy.self, from: ["date": "???"]) }.to(throwError())
        }
    }
}
