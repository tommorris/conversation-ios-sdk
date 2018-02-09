//
//  RTCConnectionTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 19/10/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxTest
import RxBlocking
import WebRTC
@testable import NexmoConversation

internal class RTCConnectionTest: QuickSpec {
    
    let connection = RTCConnection()

    // MARK:
    // MARK: Test
    
    override func spec() {
        it("remove all pop candidates with empty") {
            self.connection.close()
            self.connection.remove([])
            
            expect(self.connection.iceCandidates.isEmpty) == true
        }
        
        it("remove all pop candidates") {
            self.connection.close()
            self.connection.remove([RTCIceCandidate(sdp: "sdp", sdpMLineIndex: 1, sdpMid: "mid")])
            
            expect(self.connection.iceCandidates.isEmpty) == true
        }
        
        it("remove all pop candidates") {
            let ice = RTCIceCandidate(sdp: "sdp2", sdpMLineIndex: 1, sdpMid: "mid2")
            
            self.connection.iceCandidates.append(ice)
            self.connection.remove([ice])
            self.connection.close()
            
            expect(self.connection.iceCandidates.isEmpty) == true
        }
    }
}
