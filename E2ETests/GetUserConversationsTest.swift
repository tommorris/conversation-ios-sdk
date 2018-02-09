//
//  StatusUpdateTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class GetUserConversationsTest: QuickSpec, E2ECSConversationSpec {
    var conversationName: String = ""
    var conversation: Conversation?
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        standardSetup()
        
        it("user can retrieve list of conversations they are a member of") {
            var conversationResponse: [ConversationPreviewModel]?
            
            _ = self.client.conversation.all(with: Mock.user.uuid).subscribe(onNext: { conversation in
                conversationResponse = conversation
            }, onError: { _ in
                fail()
            })
            
            expect(conversationResponse?.count).toEventually(equal(1))
            
            guard let conversation = conversationResponse?.first else { return fail() }
            
            expect(conversation.uuid).toEventually(equal(self.conversation?.uuid))
            expect(conversation.memberId).toEventually(equal(self.conversation?.members.first?.uuid))
            expect(conversation.state).toEventually(equal(MemberModel.State.joined))
            expect(conversation.sequenceNumber).toEventually(equal(1))
        }
    }
}
