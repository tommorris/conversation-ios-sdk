//
//  EventBaseTest.swift
//  NexmoConversation
//
//  Created by shams ahmed on 06/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class EventBaseTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Test
        
        it("returns the correct raw event int value") {
            let event1: Event.EventType = .memberInvited
            let event2: Event.EventType = .memberJoined
            let event3: Event.EventType = .memberLeft
            let event4: Event.EventType = .textTypingOn
            let event5: Event.EventType = .textTypingOff
            let event6: Event.EventType = .eventDelete
            let event7: Event.EventType = .text
            let event8: Event.EventType = .textDelivered
            let event9: Event.EventType = .textSeen
            let event10: Event.EventType = .image
            let event11: Event.EventType = .imageDelivered
            let event12: Event.EventType = .imageSeen
            let event13: Event.EventType = .rtcNew
            let event14: Event.EventType = .rtcOffer
            let event15: Event.EventType = .rtcIce
            let event16: Event.EventType = .rtcAnswer
            let event17: Event.EventType = .rtcTerminate
            let event18: Event.EventType = .memberMedia
            let event19: Event.EventType = .audioPlay
            let event20: Event.EventType = .audioPlayDone
            let event21: Event.EventType = .audioSay
            let event22: Event.EventType = .audioSayDone
            let event23: Event.EventType = .audioDtmf
            let event24: Event.EventType = .audioRecord
            let event25: Event.EventType = .audioRecordDone
            let event26: Event.EventType = .audioUnmute
            let event27: Event.EventType = .audioUnearmuff
            let event28: Event.EventType = .audioSpeakingOff
            let event29: Event.EventType = .audioMute
            let event30: Event.EventType = .audioEarmuffed
            let event31: Event.EventType = .audioSpeakingOn

            expect(event1.toInt32) == 1
            expect(event2.toInt32) == 2
            expect(event3.toInt32) == 3
            expect(event4.toInt32) == 4
            expect(event5.toInt32) == 5
            expect(event6.toInt32) == 7
            expect(event7.toInt32) == 6
            expect(event8.toInt32) == 8
            expect(event9.toInt32) == 11
            expect(event10.toInt32) == 9
            expect(event11.toInt32) == 10
            expect(event12.toInt32) == 12
            expect(event13.toInt32) == 13
            expect(event14.toInt32) == 14
            expect(event15.toInt32) == 15
            expect(event16.toInt32) == 16
            expect(event17.toInt32) == 17
            expect(event18.toInt32) == 18
            expect(event19.toInt32) == 19
            expect(event20.toInt32) == 20
            expect(event21.toInt32) == 21
            expect(event22.toInt32) == 22
            expect(event23.toInt32) == 23
            expect(event24.toInt32) == 24
            expect(event25.toInt32) == 25
            expect(event26.toInt32) == 26
            expect(event27.toInt32) == 27
            expect(event28.toInt32) == 28
            expect(event29.toInt32) == 29
            expect(event30.toInt32) == 30
            expect(event31.toInt32) == 31
        }
        
        it("converts int type to raw event") {
            let event1 = Event.EventType.fromInt32(1)
            let event2 = Event.EventType.fromInt32(2)
            let event3 = Event.EventType.fromInt32(3)
            let event4 = Event.EventType.fromInt32(4)
            let event5 = Event.EventType.fromInt32(5)
            let event6 = Event.EventType.fromInt32(6)
            let event7 = Event.EventType.fromInt32(7)
            let event8 = Event.EventType.fromInt32(8)
            let event9 = Event.EventType.fromInt32(9)
            let event10 = Event.EventType.fromInt32(10)
            let event11 = Event.EventType.fromInt32(11)
            let event12 = Event.EventType.fromInt32(12)
            let event13 = Event.EventType.fromInt32(13)
            let event14 = Event.EventType.fromInt32(14)
            let event15 = Event.EventType.fromInt32(15)
            let event16 = Event.EventType.fromInt32(16)
            let event17 = Event.EventType.fromInt32(17)
            let event18 = Event.EventType.fromInt32(18)
            let event19 = Event.EventType.fromInt32(19)
            let event20 = Event.EventType.fromInt32(20)
            let event21 = Event.EventType.fromInt32(21)
            let event22 = Event.EventType.fromInt32(22)
            let event23 = Event.EventType.fromInt32(23)
            let event24 = Event.EventType.fromInt32(24)
            let event25 = Event.EventType.fromInt32(25)
            let event26 = Event.EventType.fromInt32(26)
            let event27 = Event.EventType.fromInt32(27)
            let event28 = Event.EventType.fromInt32(28)
            let event29 = Event.EventType.fromInt32(29)
            let event30 = Event.EventType.fromInt32(30)
            let event31 = Event.EventType.fromInt32(31)
            
            expect(event1) == Event.EventType.memberInvited
            expect(event2) == Event.EventType.memberJoined
            expect(event3) == Event.EventType.memberLeft
            expect(event4) == Event.EventType.textTypingOn
            expect(event5) == Event.EventType.textTypingOff
            expect(event6) == Event.EventType.text
            expect(event7) == Event.EventType.eventDelete
            expect(event8) == Event.EventType.textDelivered
            expect(event9) == Event.EventType.image
            expect(event10) == Event.EventType.imageDelivered
            expect(event11) == Event.EventType.textSeen
            expect(event12) == Event.EventType.imageSeen
            expect(event13) == Event.EventType.rtcNew
            expect(event14) == Event.EventType.rtcOffer
            expect(event15) == Event.EventType.rtcIce
            expect(event16) == Event.EventType.rtcAnswer
            expect(event17) == Event.EventType.rtcTerminate
            expect(event18) == Event.EventType.memberMedia
            expect(event19) == Event.EventType.audioPlay
            expect(event20) == Event.EventType.audioPlayDone
            expect(event21) == Event.EventType.audioSay
            expect(event22) == Event.EventType.audioSayDone
            expect(event23) == Event.EventType.audioDtmf
            expect(event24) == Event.EventType.audioRecord
            expect(event25) == Event.EventType.audioRecordDone
            expect(event26) == Event.EventType.audioUnmute
            expect(event27) == Event.EventType.audioUnearmuff
            expect(event28) == Event.EventType.audioSpeakingOff
            expect(event29) == Event.EventType.audioMute
            expect(event30) == Event.EventType.audioEarmuffed
            expect(event31) == Event.EventType.audioSpeakingOn
        }
        
        it("returns nil for unknown values") {
            let event12 = Event.EventType.fromInt32(100)
            
            expect(event12).to(beNil())
        }

        it("comapare two events") {
            let event = Event(cid: "con-123", type: .text, memberId: "mem-123")
            
            let event1 = EventBase(conversationUuid: "con-123", event: event, seen: false)
            let event2 = EventBase(conversationUuid: "con-123", event: event, seen: false)
            
            expect(event1 == event2) == true
        }
        
        it("creates a event from db") {
            let event = DBEvent(
                conversationUuid: "con-123",
                event: Event(cid: "con-123", type: .text, memberId: "mem-123"),
                seen: false
            )
            
            let baseEvent = EventBase(data: event)
            
            expect(baseEvent).toNot(beNil())
        }
        
        it("creates event from a member model") {
            let member = Member(
                conversationUuid: "con-123",
                member: MemberModel("mem-123", name: "test 1", state: .joined, userId: "usr-123", invitedBy: "demo1@nexmo.com", timestamp: [MemberModel.State.joined: Date()])
            )
            
            let baseEvent = EventBase(conversationUuid: "con-123", type: .text, member: member, seen: false)
            
            expect(baseEvent).toNot(beNil())
        }
        
        it("create a event with db factory") {
            let text = DBEvent(
                conversationUuid: "con-123",
                event: Event(cid: "con-123", type: .text, memberId: "mem-123"),
                seen: false
            )
            
            let image = DBEvent(
                conversationUuid: "con-123",
                event: Event(cid: "con-123", type: .image, memberId: "mem-123"),
                seen: false
            )
            
            let base = DBEvent(
                conversationUuid: "con-123",
                event: Event(cid: "con-123", type: .textTypingOff, memberId: "mem-123"),
                seen: false
            )
            
            let textEvent = EventBase.factory(data: text)
            let imageEvent = EventBase.factory(data: image)
            let baseEvent = EventBase.factory(data: base)
            
            expect(textEvent).toNot(beNil())
            expect(imageEvent).toNot(beNil())
            expect(baseEvent).toNot(beNil())
        }
        
        it("creates a event with event model") {
            let text = Event(cid: "con-123", type: .text, memberId: "mem-1")
            let image = Event(cid: "con-123", type: .image, memberId: "mem-1")
            let base = Event(cid: "con-123", type: .textTypingOff, memberId: "mem-1")
            
            let textEvent = EventBase.factory(conversationUuid: "con-123", event: text, seen: false)
            let imageEvent = EventBase.factory(conversationUuid: "con-123", event: image, seen: false)
            let baseEvent = EventBase.factory(conversationUuid: "con-123", event: base, seen: false)
            
            expect(textEvent).toNot(beNil())
            expect(imageEvent).toNot(beNil())
            expect(baseEvent).toNot(beNil())
            expect(baseEvent.id).toNot(beNil())
        }
        
        it("forms a id from conversation id and event") {
            let base = EventBase.conversationEventId(from: "123:456")
            
            expect(base.1) == "456"
        }
        
        it("has a created body from a db event") {
            let event = Event(cid: "con-123", id: "1", from: "mem-1", to: nil, timestamp: Date(), type: .text)
            event.body = ["text": "message 1"]
            
            let base = DBEvent(
                conversationUuid: "con-123",
                event: event,
                seen: false
            )
            
            expect(base.body).toNot(beNil())
        }
        
        it("has a created date from a event") {
            let event = Event(cid: "con-123", id: "1", from: "mem-1", to: nil, timestamp: Date(), type: .text)
            event.body = ["text": "message 1"]
            
            let base = DBEvent(
                conversationUuid: "con-123",
                event: event,
                seen: false
            )
            
            let textEvent = EventBase.factory(data: base)
            
            expect(textEvent.createDate).toNot(beNil())
        }
        
        it("when getting body from string it returns empty array") {
            let event = Event(cid: "con-123", id: "1", from: "mem-1", to: nil, timestamp: Date(), type: .text)
            
            let base = DBEvent(
                conversationUuid: "con-123",
                event: event,
                seen: false
            )
            
            expect(base.body.isEmpty) == true
        }
        
        it("has has valid members") {
            let mock = SimpleMockDatabase()
            let baseEvent = EventBase.factory(conversationUuid: mock.conversation1.rest.uuid, event: mock.event1, seen: false)
            
            expect(baseEvent.from).toNot(beNil())
        }
    }
}
