//
//  KickAndRejectedTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class KickTest: QuickSpec, E2ECSConversationSpec {
    var conversationName: String = ""
    var conversation: Conversation?
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        standardSetup()
        
        it("user can issue kick on their own member") {
            guard let selfMember = self.conversation?.members.first else { return fail() }
            
            var responseStatus: Bool?
            
            _ = selfMember.kick().subscribe(onSuccess: { _ in
                responseStatus = true
            }, onError: { _ in
                fail()
            })
            
            expect(responseStatus).toEventually(beTrue())
            expect(self.conversation?.state).toEventually(equal(MemberModel.State.left))
            expect(self.conversation?.members.first?.state).toEventually(equal(MemberModel.State.left))
        }
        
        it("user can leave a conversation they are a member of") {
            var responseStatus: Bool?
            
            _ = self.conversation?.leave().subscribe(onSuccess: { _ in
                responseStatus = true
            }, onError: { _ in
                fail()
            })
            
            expect(responseStatus).toEventually(beTrue())
            expect(self.conversation?.state).toEventually(equal(MemberModel.State.left))
            expect(self.conversation?.members.first?.state).toEventually(equal(MemberModel.State.left))
        }
    }
}
