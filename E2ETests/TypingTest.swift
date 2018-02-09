//
//  TypingTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class TypingTest: QuickSpec, E2ECSConversationSpec {
    var conversationName: String = ""
    var conversation: Conversation?
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        standardSetup()
        
        it("user can send typing on event to a conversation they are a member of") {
            expect(self.conversation?.members.first?.typing.value).to(beFalse())
            
            let result = self.conversation?.startTyping()
            
            expect(result) == true
            expect(self.conversation?.members.first?.typing.value).toEventually(beTrue())
        }
        
        it("user can send typing off event to a conversation they are a member of") {
            expect(self.conversation?.members.first?.typing.value).to(beFalse())
            
            var result = self.conversation?.startTyping()
            
            expect(result) == true
            expect(self.conversation?.members.first?.typing.value).toEventually(beTrue())
            
            result = self.conversation?.stopTyping()
            
            expect(result) == true
            expect(self.conversation?.members.first?.typing.value).toEventually(beFalse())
        }
    }
}
