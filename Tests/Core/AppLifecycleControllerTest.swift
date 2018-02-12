//
//  AppLifecycleControllerTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 01/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import Quick
import Nimble
import Mockingjay
import RxTest
import RxBlocking
@testable import NexmoConversation

internal class AppLifecycleControllerTest: QuickSpec {
    
    let network = NetworkController(token: "token")
    lazy var appLifeCycleController: AppLifecycleController = {
        return AppLifecycleController(networkController: self.network)
    }()
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("compare application state matches") {
            let result = ApplicationState.active == ApplicationState.active
            
            expect(result) == true
        }
        
        it("fail application state match check") {
            let result = ApplicationState.active == ApplicationState.terminated
            
            expect(result) == false
        }

        // DISABLED
        it("receives remote notifications passes") {
            var newNotification: PushNotificationController.RemoteNotification?
            
            // TODO: add fake uiapplication mock
            _ = self.appLifeCycleController.receiveRemoteNotification.subscribe(onNext: { notification in
                newNotification = notification
            })
            
            expect(newNotification).toEventuallyNot(beNil())
        }

        // DISABLED
        it("receives application state") {
            var newState: ApplicationState?
            // TODO: add fake uiapplication mock
            _ = self.appLifeCycleController.applicationState.subscribe(onNext: { state in
                newState = state
            })
            
            expect(newState).toEventuallyNot(beNil())
        }

        it("returns notifications observable") {
            let dispose = self.appLifeCycleController.notifications.subscribe(onNext: { _ in

            })

            expect(dispose).toNot(beNil())
        }
    }
}
