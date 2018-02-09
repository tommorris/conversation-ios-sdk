//
//  UNUserNotificationCenterTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 22/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import UserNotifications
@testable import NexmoConversation

internal class UNUserNotificationCenterTest: QuickSpec {

    // MARK:
    // MARK: Test

    override func spec() {
        it("bind for notification") {
            // TODO: Calling UserNotifications crashes in unit test mode
            // See: http://www.openradar.me/27286490
        }
    }
}
