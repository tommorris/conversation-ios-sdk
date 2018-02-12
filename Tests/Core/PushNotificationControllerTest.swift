//
//  PushNotificationControllerTest.swift
//  NexmoConversation
//
//  Created by paul calver on 17/11/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxBlocking
@testable import NexmoConversation

internal class PushNotificationControllerTest: QuickSpec {
    
    let network = NetworkController(token: "token")
    lazy var pushNotificationController: PushNotificationController = {
        let controller = PushNotificationController(networkController: self.network)
        return controller
    }()
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        
    }
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        beforeEach {
            self.setup()
        }
        
        it("fails to register for remote notifications") {
            var newState: PushNotificationController.State?
            
            _ = UIApplication.shared.rx.registerForRemoteNotificationsFailed.subscribe(onNext: { state in
                newState = state
            })
            
            expect(newState).toEventually(beNil())
        }
        
        // MARK:
        // MARK: Device token
        
        it("update device token") {
            self.stubCreated(with: PushNotificationRouter.updateDevice(id: "id", deviceToken: Data()).urlRequest)
            
            guard let token = "testing...".data(using: .utf8) else { return fail() }
            
            guard let result = try? self.pushNotificationController.update(deviceToken: token, deviceId: "id")
                .toBlocking()
                .first() else { return fail() }
            
            expect(result) == true
        }
        
        it("fails to update device token") {
            self.stubServerError(request: PushNotificationRouter.updateDevice(id: "id", deviceToken: Data()).urlRequest)
            
            guard let token = "testing...".data(using: .utf8) else { return fail() }
            
            var error: Error?
            
            _ = self.pushNotificationController.update(deviceToken: token, deviceId: "id").subscribe(onNext: { _ in
                
            }, onError: { serverError in
                error = serverError
            })
            
            expect(error).toEventuallyNot(beNil())
        }
        
        it("update device token will nil") {
            guard let token = "testing...".data(using: .utf8) else { return fail() }
            
            guard let result = try? self.pushNotificationController.update(deviceToken: token, deviceId: nil)
                .toBlocking()
                .first() else { return fail() }
            
            expect(result) == false
        }
        
        it("makes request to remove device token from account") {
            self.stubCreated(with: PushNotificationRouter.deleteDeviceToken(id: "id").urlRequest)
            
            guard let result = try? self.pushNotificationController.removeDeviceToken(deviceId: "id")
                .toBlocking()
                .first() else { return fail() }
            
            expect(result) == true
        }
        
        // DISABLED
        xit("registers for remote notifications") {
            var newState: PushNotificationController.State?
            
            // TODO: add fake uiapplication mock
            _ = self.pushNotificationController.state.subscribe(onNext: { state in
                newState = state
            })
            
            expect(newState).toEventuallyNot(beNil())
        }
        
        it("sends device token") {
            var state: PushNotificationController.State?
            
            _ = self.pushNotificationController.state.subscribe(onNext: { newState in
                state = newState
            })
            
            self.pushNotificationController.registeredForRemoteNotifications(with: Data())
            
            expect(state).toEventuallyNot(beNil())
        }
    }
}
