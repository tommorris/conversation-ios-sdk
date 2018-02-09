//
//  NotificationTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 22/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class NotificationTest: QuickSpec {

    // MARK:
    // MARK: Test

    override func spec() {
        it("compares notification states") {
            let simple = SimpleMockDatabase()
            let network = NetworkController(token: "")
            let account = AccountController(network: network)
            let conversation = ConversationController(network: network, account: account, rtc: RTCController(network: network))
            let membership = MembershipController(network: network)
            let storage = Storage(account: account, conversation: conversation, membershipController: membership)
            let event = EventController(network: network, storage: storage)
            let queue = EventQueue(storage: storage, event: event)

            storage.eventQueue = queue
            storage.eventController = event

            let conversation1 = Conversation(simple.conversation1,
                                             eventController: event,
                                             databaseManager: storage.databaseManager,
                                             eventQueue: queue,
                                             account: account,
                                             conversationController: conversation,
                                             membershipController: membership
            )

            let text = TextEvent(data: simple.DBEvent1)
            let image = ImageEvent(data: simple.DBEvent1)

            let deleted = ConversationCollection.T.deleted(conversation1)
            let updated = ConversationCollection.T.updated(conversation1)
            let inserted = ConversationCollection.T.inserted(conversation1, .new)

            expect(AppLifecycleController.Notification.conversation(deleted)) == AppLifecycleController.Notification.conversation(deleted)
            expect(AppLifecycleController.Notification.conversation(updated)) == AppLifecycleController.Notification.conversation(updated)
            expect(AppLifecycleController.Notification.conversation(inserted)) == AppLifecycleController.Notification.conversation(inserted)
            expect(AppLifecycleController.Notification.text(text)) == AppLifecycleController.Notification.text(text)
            expect(AppLifecycleController.Notification.image(image)) == AppLifecycleController.Notification.image(image)
        }

        it("fails to compare notification states") {
            let simple = SimpleMockDatabase()
            let network = NetworkController(token: "")
            let account = AccountController(network: network)
            let conversation = ConversationController(network: network, account: account, rtc: RTCController(network: network))
            let membership = MembershipController(network: network)
            let storage = Storage(account: account, conversation: conversation, membershipController: membership)
            let event = EventController(network: network, storage: storage)
            let queue = EventQueue(storage: storage, event: event)

            storage.eventQueue = queue
            storage.eventController = event

            let conversation1 = Conversation(simple.conversation1,
                                             eventController: event,
                                             databaseManager: storage.databaseManager,
                                             eventQueue: queue,
                                             account: account,
                                             conversationController: conversation,
                                             membershipController: membership
            )

            let text = TextEvent(data: simple.DBEvent1)
            let image = ImageEvent(data: simple.DBEvent1)

            let deleted = ConversationCollection.T.deleted(conversation1)
            let updated = ConversationCollection.T.updated(conversation1)
            let inserted = ConversationCollection.T.inserted(conversation1, .new)

            expect(AppLifecycleController.Notification.conversation(deleted)) != AppLifecycleController.Notification.conversation(inserted)
            expect(AppLifecycleController.Notification.conversation(updated)) != AppLifecycleController.Notification.conversation(inserted)
            expect(AppLifecycleController.Notification.conversation(inserted)) != AppLifecycleController.Notification.conversation(deleted)
            expect(AppLifecycleController.Notification.conversation(inserted)) != AppLifecycleController.Notification.image(image)
            expect(AppLifecycleController.Notification.text(text)) != AppLifecycleController.Notification.image(image)
            expect(AppLifecycleController.Notification.image(image)) != AppLifecycleController.Notification.text(text)
        }
    }
}
