//
//  WebSocketLoggerTest.swift
//  NexmoConversation
//
//  Created by shams ahmed on 01/04/2017.
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

internal class WebSocketLoggerTest: QuickSpec {
    
    let logger = WebSocketLogger()
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("doesnt print log") {
            self.logger.log = false
            
            self.logger.error("test")
        }
        
        it("prints socket log") {
            self.logger.log = true
            
            self.logger.log("Adding engine")
            self.logger.log("Starting engine. Server: %@")
            self.logger.log("Handshaking")
            self.logger.log("Sending ws: %@ as type: %@")
            self.logger.log("Should parse message: %@")
            self.logger.log("Adding handler for event: %@")
            self.logger.log("Connect")
            self.logger.log("Emitting: %@")
            self.logger.log("Writing ws: %@")
            self.logger.log("Engine is being closed.")
            self.logger.log("Got message: %@")
            self.logger.log("Writing ws: %@ has data: %@")
            self.logger.log("Parsing %@")
            self.logger.log("Decoded packet as: %@")
            self.logger.log("Handling event: %@ with data: %@")
            self.logger.log("Handling event: %@ with data: %@")
            self.logger.log("Handling event: %@ with data: %@")
            self.logger.log("Handling event: %@ with data: %@")
            self.logger.log("Handling event: %@ with data: %@")
            self.logger.log("Handling event: %@ with data: %@")
            self.logger.log("session:success")
            self.logger.log("Closing socket")
            self.logger.log("Disconnected")
            self.logger.log("xxx")
        }
    }
}
