//
//  StatusTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class GetConversationEventsTest: QuickSpec, E2ECSConversationSpec {
    var conversation: Conversation?    
    var conversationName: String = ""
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        standardSetup()
        
        it("user can retrieve text events for a conversation they are a member of") {
            guard let conversation = self.client.conversation.conversations.first else { return fail() }
            guard let _ = try? conversation.send(TestConstants.Text.text) else { return fail() }
            
            expect(conversation.events.count).toEventually(equal(2))
            expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
            expect((conversation.events.last as? TextEvent)?.text).toEventually(equal(TestConstants.Text.text))
            
            //BasicOperations.logout(client: self.client)
            //BasicOperations.login(with: self.client, using: self.token)
            
            guard let firstConversation = self.client.conversation.conversations.first else { return fail() }
            expect(firstConversation.events.count).toEventually(equal(2))
            expect(firstConversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
            expect((firstConversation.events.last as? TextEvent)?.text).toEventually(equal(TestConstants.Text.text))
        }
        
        it("user can retrieve image events for a conversation they are a member of") {
            guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
            guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
            
            guard let conversation = self.client.conversation.conversations.first else { return fail() }
            guard let _ = try? conversation.send(data) else { return fail() }
            
            expect(conversation.events.count).toEventually(equal(2))
            expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
            
            //BasicOperations.logout(client: self.client)
            //BasicOperations.login(with: self.client, using: self.token)
            
            guard let firstConversation = self.client.conversation.conversations.first else { return fail() }
            expect(firstConversation.events.count).toEventually(equal(2))
            expect(firstConversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
        }
    }
}
