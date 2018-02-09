//
//  AudioTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 19/10/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class AudioTest: QuickSpec {

    lazy var conversation: Conversation = {
        let conversation = Conversation(SimpleMockDatabase().conversation1,
                                        eventController: ConversationClient.instance.eventController,
                                        databaseManager: ConversationClient.instance.storage.databaseManager,
                                        eventQueue: ConversationClient.instance.eventController.queue,
                                        account: ConversationClient.instance.account,
                                        conversationController: ConversationClient.instance.conversation,
                                        membershipController: ConversationClient.instance.membershipController
        )

        return conversation
    }()

    lazy var audio: Audio = {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { self.conversation.refreshMembers() })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: { self.conversation.refreshMembers() })

        return Audio(with: self.conversation)
    }()

    // MARK:
    // MARK: Test

    override func spec() {

        beforeEach {
            self.conversation.refreshMembers()
            ConversationClient.instance.account.userId = "usr-1"
        }

        it("enable audio") {
            self.stub(file: .rtcNew, request: RTCRouter.new(conversationId: "con-1", from: RTCService.New(from: "mem-123", sdp: "SDP", id: "session-id")).urlRequest)

            self.audio.state.value = .idle

            self.audio.disable()

            do {
                let state = try self.audio.enable()

                _ = state.subscribe(onError: { _ in fail() })
            } catch Audio.Errors.isAlreadyConnected {
                fail()
            } catch Audio.Errors.isAlreadyEnabled {
                fail()
            } catch Audio.Errors.userHasNotGrantedPermission {
                fail()
            } catch Audio.Errors.userHasEnabledAudioInAnotherConversation {
                fail()
            } catch {
                fail()
            }

            expect(self.audio.description).toNot(beNil())
            expect(self.audio.debugDescription).toNot(beNil())
            expect(self.audio.id).toEventually(equal("c484306e-1126-4264-a327-62a4674ec385"), timeout: 10)
        }

        it("enable audio for objective-c support fails wile connected") {
            self.audio.stateObjc { _ in }
            self.audio.state.value = .connected
            
            let result = self.audio.enable { _ in }
            
            expect(result).toNot(beNil())
            
            self.audio.state.value = .idle
        }

        it("enable audio for objective-c support") {
            self.audio.state.value = .idle
            self.audio.stateObjc { _ in }

            let result = self.audio.enable { _ in }

            expect(result).to(equal(Audio.Errors.userHasEnabledAudioInAnotherConversation))
        }

        it("disable audio") {
            self.audio.id = "rtc-1"

            if !self.audio.state.isConnectState {
                _ = try? self.audio.enable()
            }

            self.audio.disable()

            expect(self.audio.id).to(beNil())
        }

        it("fails to enable audio") {
            self.audio.state.value = .connected

            do {
                _ = try self.audio.enable()

                fail()
            } catch let error {
                expect(error).toNot(beNil())
            }
        }

        it("enable audio fails to send rtc new") {
            self.stubServerError(request: RTCRouter.new(conversationId: "con-1", from: RTCService.New(from: "MEM-123", sdp: "SDP", id: "session-id")).urlRequest)

            var error: Error?

            do {
                try self.audio.enable()
            } catch let newError {
                error = newError
            }

            expect(error).toEventuallyNot(beNil())
        }

        it("enable audio fails to send rtc new to capi") {
            self.stubServerError(request: RTCRouter.new(conversationId: "con-1", from: RTCService.New(from: "MEM-123", sdp: "SDP", id: "session-id")).urlRequest)

            var state: Audio.State?

            do {
                self.audio.disable()
                
                _ = try self.audio.enable().subscribe(onNext: { newState in
                    state = newState
                })
            } catch {
                fail()
            }

            expect(state).toEventually(equal(.failed))

            self.audio.disable()
        }

        it("enable audio fails with bad conversation setup") {
            let conversation = Conversation(SimpleMockDatabase().emptyConversation,
                                            eventController: ConversationClient.instance.eventController,
                                            databaseManager: ConversationClient.instance.storage.databaseManager,
                                            eventQueue: ConversationClient.instance.eventController.queue,
                                            account: ConversationClient.instance.account,
                                            conversationController: ConversationClient.instance.conversation,
                                            membershipController: ConversationClient.instance.membershipController
            )

            let audio: Audio? = Audio(with: conversation)
            var state: Audio.State?

            audio?.disable()
            
            do {
                _ = try audio?.enable().subscribe(onNext: { newState in
                    state = newState
                })
            } catch {
                fail()
            }

            expect(state).toEventually(equal(.failed))

            let result = audio == audio

            expect(result) == true
        }

        it("enable audio fails with bad conversation setup") {
            let db = DBConversation(conversation: ConversationModel(
                uuid: "con-3", 
                name: "conversation 3", 
                sequenceNumber: 3,
                members: [], 
                created: Date(), 
                displayName: "conversation 3", 
                state: .invited, 
                memberId: "mem-3")
            )

            let conversation = Conversation(db,
                                            eventController: ConversationClient.instance.eventController,
                                            databaseManager: ConversationClient.instance.storage.databaseManager,
                                            eventQueue: ConversationClient.instance.eventController.queue,
                                            account: ConversationClient.instance.account,
                                            conversationController: ConversationClient.instance.conversation,
                                            membershipController: ConversationClient.instance.membershipController
            )

            let audio: Audio? = Audio(with: conversation)
            audio?.state.value = .connected

            let result = try? audio?.enable()

            expect(result).toEventually(beNil())

            audio?.disable()

            expect(audio?.id).toEventually(beNil())
        }

        it("xxx fails to mute audio") {
            self.audio.id = nil

            let current = self.audio.mute

            self.audio.mute = self.audio.mute

            expect(self.audio.mute).to(equal(current))
        }

        xit("mutes audio") {
            _ = SimpleMockDatabase()

            let request = RTC.Request(id: "rtc-1", conversationId: "con-1", to: "mem-123", type: .audioMute)

            self.stub(file: .muteAndUnmute, request: RTCRouter.send(event: request).urlRequest)

            self.audio.id = "rtc-1"
            self.audio.mute = true

            expect(self.audio.mute).toEventually(equal(true))
        }

        xit("unmutes audio") {
            _ = SimpleMockDatabase()

            let request = RTC.Request(id: "rtc-1", conversationId: "con-1", to: "mem-123", type: .audioMute)

            self.stub(file: .muteAndUnmute, request: RTCRouter.send(event: request).urlRequest)

            self.audio.id = "rtc-1"
            self.audio.mute = false

            expect(self.audio.mute).toEventually(equal(false))
        }

        it("turns on loudspeaker") {
            self.audio.loudspeaker = true

            expect(self.audio.loudspeaker).to(equal(true))
        }

        it("turns off loudspeaker") {
            self.audio.loudspeaker = false

            expect(self.audio.loudspeaker).to(equal(false))
        }

        xit("connects to a remote audio session") {
            guard let json = self.array(path: .rtcAnswerFromSocket).first as? [String: Any],
                let answer = try? JSONDecoder().decode(RTC.Answer.self, from: json) else {
                return fail()
            }

            self.audio.connect(with: answer)

            expect(self.audio.state.value).toEventuallyNot(equal(Audio.State.failed))
        }
        
        it("turns off earmuff") {
            self.audio.earmuff = false
            
            expect(self.audio.earmuff).to(equal(false))
        }
        
        it("turns on earmuff") {
            self.audio.earmuff = true
            
            expect(self.audio.earmuff).to(equal(true))
        }
        
        it("turns on hold") {
            self.audio.hold = true
            
            expect(self.audio.loudspeaker).to(equal(true))
        }
        
        it("turns off hold") {
            self.audio.hold = false
            
            expect(self.audio.loudspeaker).to(equal(false))
        }
    }
}
