//
//  Storage.swift
//  NexmoConversation
//
//  Created by James Green on 31/08/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

internal class Storage {

    internal let databaseManager = DatabaseManager()

    internal let fileCache: DiskCache = {
        // TODO: add code to move to tmp files, when feature flag is built to avoid auto download
        return DiskCache(with: (Constants.SDK.documentPath as NSString).appendingPathComponent("Files"))
    }()

    internal let conversationCache = ObjectCache<Conversation>()
    internal let memberCache = ObjectCache<Member>()
    internal let userCache = ObjectCache<User>()
    internal let eventCache = ObjectCache<EventBase>()
    internal let receiptCache = ObjectCache<ReceiptRecord>()
    
    /// Must be set after init()
    internal weak var eventQueue: EventQueue?
    
    /// Must be set after init()
    internal var eventController: EventController?
    
    private let account: AccountController
    private let conversation: ConversationController
    private let membershipController: MembershipController

    // MARK:
    // MARK: Initializers
    
    internal init(account: AccountController,
                  conversation: ConversationController,
                  membershipController: MembershipController) {
        self.account = account
        self.conversation = conversation
        self.membershipController = membershipController
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        conversationCache.setGenerator { [unowned self](/* uuid */uuid) in
            if Environment.inDebug && (self.eventQueue == nil || self.eventController == nil) {
                assertionFailure("setup not complete")
            }
            
            guard let conversation = self.databaseManager.conversation[uuid] else { return nil }
            guard let eventQueue = self.eventQueue else { return nil }
            guard let eventController = self.eventController else { return nil }

            return Conversation(conversation,
                                   eventController: eventController,
                                   databaseManager: self.databaseManager,
                                   eventQueue: eventQueue,
                                   account: self.account,
                                   conversationController: self.conversation,
                                   membershipController: self.membershipController
            )
        }
        
        memberCache.setGenerator { [unowned self](/* uuid */uuid) in
            guard let member = self.databaseManager.member[uuid] else { return nil }
            
            return Member(data: member)
        }
        
        userCache.setGenerator { [unowned self](/* uuid */uuid) in
            guard let user = self.databaseManager.user[uuid] else { return nil }
            
            return User(data: user)
        }
        
        eventCache.setGenerator { [unowned self](/* uuid */uuid) in
            let (conversationUuid, eventId) = EventBase.conversationEventId(from: uuid)
            
            guard let event = self.databaseManager.event[with :eventId, in: conversationUuid] else { return nil }
            
            return EventBase.factory(data: event)
        }
        
        receiptCache.setGenerator { [unowned self](/* uuid */uuid) in
            let (memberId, eventId) = ReceiptRecord.UUIDtoMemberAndEvent(receiptUuid: uuid)
            
            guard let receipt = self.databaseManager.receipt[memberId, for: eventId] else { return nil }
                
            return ReceiptRecord(data: receipt)
        }
    }

    // MARK:
    // MARK: Cleaning

    /// Clears all caches.
    internal func clear() {
        conversationCache.clear()
        memberCache.clear()
        userCache.clear()
        eventCache.clear()
        receiptCache.clear()
    }
    
    /// Reset all data stored on the device
    internal func reset() throws {
        fileCache.removeAll()
        clear() // clear memory cache
        
        try databaseManager.clear()
    }
}
