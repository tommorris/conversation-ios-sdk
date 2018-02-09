//
//  RTCControllerTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 26/09/2017.
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

internal class RTCControllerTest: QuickSpec {

    let client = ConversationClient.instance

    // MARK:
    // MARK: Test

    override func spec() {
        it("creates a new call") {
            let conversationId = "CON-123"
            let model = RTCService.New(from: "MEM-123", sdp: "xxx", id: "session-id")
            
            self.stub(file: .rtcNew, request: RTCRouter.new(conversationId: conversationId, from: model).urlRequest)

            _ = self.client.conversation.media.invitations.subscribe()

            let response = try? self.client
                .conversation
                .media
                .new(conversationId, from: model.from, with: model.sdp)
                .toBlocking()
                .first()

            expect(response).toNot(beNil())
            expect(response??.id.isEmpty) == false
        }

        it("fail to creates a new call") {
            let conversationId = "CON-123"
            let model = RTCService.New(from: "MEM-123", sdp: "xxx", id: "session-id")

            self.stubServerError(request: RTCRouter.new(conversationId: conversationId, from: model).urlRequest)

            let response = try? self.client
                .conversation
                .media
                .new(conversationId, from: model.from, with: model.sdp)
                .toBlocking()
                .first()

            expect(response).to(beNil())
        }

        it("fail to creates a new audio call with incorrect json") {
            let conversationId = "CON-123"
            let model = RTCService.New(from: "MEM-123", sdp: "xxx", id: "session-id")

            self.stub(json: [:], request: RTCRouter.new(conversationId: conversationId, from: model).urlRequest)

            let response = try? self.client
                .conversation
                .media
                .new(conversationId, from: model.from, with: model.sdp)
                .toBlocking()
                .first()

            expect(response).to(beNil())
        }

        it("ends a existing call") {
            let conversationId = "CON-123"

            self.stubOk(with: RTCRouter.terminate(conversationId: conversationId, RTCId: "RTC-123", memberId: "MEM-123").urlRequest)

            var isComplete: Bool = false

            _ = self.client.conversation.media.end("RTC-123", in: conversationId, from: "MEM-123").subscribe(onCompleted: {
                isComplete = true
            })

            expect(isComplete).toEventually(beTrue())
        }

        it("fail to end a existing call") {
            let conversationId = "CON-123"

            self.stubServerError(request: RTCRouter.terminate(conversationId: conversationId, RTCId: "RTC-123", memberId: "MEM-123").urlRequest)

            var error: Error?

            _ = self.client.conversation.media.end("RTC-123", in: conversationId, from: "MEM-123").subscribe(onError: { newError in
                error = newError
            })

            expect(error).toEventuallyNot(beNil())
        }

        it("sends audio mute") {
            self.stub(file: .muteAndUnmute, request: RTCRouter.send(event: RTC.Request(
                id: "rtc-1",
                conversationId: "con-1",
                to: "mem-1",
                type: .audioMute)).urlRequest)

            var isComplete: Bool = false

            _ = self.client.conversation.media.send("rtc-1", in: "con-1", to: "mem-1", with: .audioMute).subscribe(onCompleted: {
                isComplete = true
            })

            expect(isComplete).toEventually(beTrue())
        }

        it("fails to send audio mute") {
            self.stubServerError(request: RTCRouter.send(event: RTC.Request(id: "rtc-1", conversationId: "con-1", to: "mem-1", type: .audioUnmute)).urlRequest)

            var error: Error?

            _ = self.client.conversation.media.send("rtc-1", in: "con-1", to: "mem-1", with: .audioMute)
                .subscribe(onError: { error = $0 })

            expect(error).toEventuallyNot(beNil())
        }
        
        it("enables audio") {
            _ = SimpleMockDatabase()
            
            guard let conversation = self.client.conversation.conversations["con-1"] else { return fail() }
            
            expect { try conversation.audio.enable() }.toNot(throwAssertion())

            conversation.audio.disable()

            expect(conversation.audio.id).toEventually(beNil())
        }

        it("disables audio") {
            _ = SimpleMockDatabase()

            self.client.conversation.conversations.refetch()

            guard let conversation = self.client.conversation.conversations.first else { return fail() }
            
            conversation.audio.state.value = .idle

            expect { try self.client.conversation.media.enabled(media: conversation.audio) }.toNot(throwAssertion())
            
            conversation.audio.loudspeaker = true
            conversation.audio.id = "rtc-1"

            let result = self.client.conversation.media.disabled(media: conversation.audio)

            // stop crash here
            conversation.audio.disable()
            
            // TOOD: research why conversation object get's lost here 
            expect(result).to(beTrue())
            expect(conversation.audio.id).toEventually(beNil())
        }

        it("disable audio fails") {
            expect(self.client.conversation.media.disabled(media: nil)) == false
        }
        
        it("connects to a answer fails with unknown rtc id") {
            guard let json = self.array(path: .rtcAnswerFromSocket).first as? [String: Any] else { return fail() }
            guard let model = try? JSONDecoder().decode(RTC.Answer.self, from: json) else { return fail() }
            
            self.client.conversation.media.answers.value = model
            
            expect(self.client.conversation.media.answers.value).toNot(beNil())
        }
        
        it("fails to connects to a answer with unknown rtc id") {
            guard let json = self.array(path: .rtcAnswerFromSocket).first as? [String: Any] else { return fail() }
            guard let model = try? JSONDecoder().decode(RTC.Answer.self, from: json) else { return fail() }
            
            let controller = RTCController(network: NetworkController())
            
            controller.answers.value = model
            
            expect(controller.answers.value).toNot(beNil())
        }
        
        it("connects to a answer") {
            guard let json = self.array(path: .rtcAnswerFromSocket).first as? [String: Any] else { return fail() }
            guard let model = try? JSONDecoder().decode(RTC.Answer.self, from: json) else { return fail() }
            guard let conversation = self.client.conversation.conversations["con-1"] else { return fail() }
            
            expect { try conversation.audio.enable() }.toNot(throwAssertion())
            
            conversation.audio.id = model.id
            
            self.client.conversation.media.answers.value = model
            
            expect(self.client.conversation.media.answers.value).toNot(beNil())
            
            conversation.audio.disable()
        }
    }
}
