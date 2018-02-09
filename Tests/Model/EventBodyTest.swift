//
//  EventBodyTest.swift
//  NexmoConversation
//
//  Created by shams ahmed on 05/07/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxTest
import RxBlocking
@testable import NexmoConversation

internal class EventBodyTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Text Test
        
        it("creates a text event model") {
            let model = try? JSONDecoder().decode(Event.Body.Text.self, from: ["text": "test"])
            
            expect(model).toNot(beNil())
        }
        
        it("fails to create a text model") {
            let model = try? JSONDecoder().decode(Event.Body.Text.self, from: [:])
            
            expect(model).to(beNil())
        }

        // MARK:
        // MARK: Image Test

        it("creates a image event model") {
            expect(Event.Body.Image(json: ["image": "test"])).to(beNil())
        }
        
        it("fails to create a image model") {
            expect(Event.Body.Image(json: [:])).to(beNil())
        }

        // MARK:
        // MARK: Delete Test
        
        it("creates a delete event model") {
            let model = try? JSONDecoder().decode(Event.Body.Delete.self, from: ["event_id": "event-1"])
            
            expect(model).toNot(beNil())
        }
        
        it("fails to create a delete model") {
            let model = try? JSONDecoder().decode(Event.Body.Delete.self, from: [:])
            
            expect(model).to(beNil())
        }

        // MARK:
        // MARK: Member Invite Test

        it("creates a member invite model") {
            guard let body = self.json(path: .memberInvitedViaSocket)["body"] as? [String: Any] else { return fail() }
            
            let model = try? JSONDecoder().decode(Event.Body.MemberInvite.self, from: body)
            
            expect(model).toNot(beNil())
        }

        it("fails to creates a member invite model") {
            let json = JSONDecoder()
            
            expect(try? json.decode(Event.Body.MemberInvite.self, from: [:])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.self, from: ["cname": "", "invited_by": "", "user": ["member_id": "", "name": "", "user_id": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.self, from: ["cname": "", "invited_by": "", "user": ["member_id": "", "name": "", "user_id": ""], "timestamp": ["": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.self, from: ["cname": ""])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.self, from: ["cname": "", "timestamp": ["invited": "2017-07-31T13:16:16.091Z"], "invited_by": "", "user": [:]])).to(beNil())
        }

        it("fails to create member invite user model") {
            let json = JSONDecoder()
            
            expect(try? json.decode(Event.Body.MemberInvite.User.self, from: [:])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.User.self, from: ["user": ["": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.User.self, from: ["user": ["member_id": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberInvite.User.self, from: ["user": ["member_id": "", "user_id": ""]])).to(beNil())
        }
        
        // MARK:
        // MARK: Member Left Test
        
        it("creates a member left model") {
            guard let body = self.json(path: .memberLeftViaSocket)["body"] as? [String: Any] else { return fail() }
            
            let model = try? JSONDecoder().decode(Event.Body.MemberLeft.self, from: body)
            
            expect(model).toNot(beNil())
            expect(model?.timestamp.count) == 2
            expect(model?.user.userId) == "USR-b58e90e3-953b-4600-a2cb-8f6cd14c2fdb"
        }
        
        it("fails to creates a member left model") {
            let json = JSONDecoder()
            
            expect(try? json.decode(Event.Body.MemberLeft.self, from: [:])).to(beNil())
            expect(try? json.decode(Event.Body.MemberLeft.self, from: ["user": ["name": "", "id": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberLeft.self, from: ["user": ["name": "", "id": ""], "timestamp": ["": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberLeft.self, from: ["timestamp": ["left": "2017-07-31T13:16:16.091Z"], "user": [:]])).to(beNil())
        }
        
        it("fails to create member left user model") {
            let json = JSONDecoder()
            
            expect(try? json.decode(Event.Body.MemberLeft.self, from: [:])).to(beNil())
            expect(try? json.decode(Event.Body.MemberLeft.self, from: ["user": ["": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberLeft.self, from: ["user": ["id": ""]])).to(beNil())
            expect(try? json.decode(Event.Body.MemberLeft.self, from: ["user": ["name": ""]])).to(beNil())
        }
        
        // MARK:
        // MARK: Deleted Test
        
        it("creates a deleted event") {
            let event = Event.Body.Deleted(with: Date())
            
            expect(event.timestamp).toNot(beNil())
            expect(event.json).toNot(beNil())
        }
    }
}
