//
//  PostMessageTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/12/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import NexmoConversation

class DeleteEventTest: QuickSpec, E2ECSConversationSpec {
    var conversation: Conversation?
    var conversationName: String = ""
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        standardSetup()
        
        it("user can delete their own sent text") {
            guard let conversation = self.client.conversation.conversations.first else { return fail() }
            guard let _ = try? conversation.send(TestConstants.Text.text) else { return fail() }
            
            expect(conversation.events.count).toEventually(equal(2))
            expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
            
            let success = (conversation.events.last as? TextEvent)?.delete()
            
            expect(success).toEventually(beTrue())
            expect((conversation.events.last as? TextEvent)?.text).toEventually(beNil())
        }
        
        it("user can delete their own sent image") {
            guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
            guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }
            
            guard let conversation = self.client.conversation.conversations.first else { return fail() }
            guard let _ = try? conversation.send(data) else { return fail() }
            
            expect(conversation.events.count).toEventually(equal(2))
            expect(conversation.events.last?.uuid).toEventually(equal(conversation.uuid + ":2"))
            
            var thumbnailImage: UIImage?
            (conversation.events.last as? ImageEvent)?.image( { result in
                switch result {
                case .success(let newImage): thumbnailImage = newImage
                default: fail()
                }
            })
            
            expect(thumbnailImage).toEventuallyNot(beNil())
            
            let success = (conversation.events.last as? ImageEvent)?.delete()
            
            expect(success).toEventually(beTrue())
            
            (conversation.events.last as? ImageEvent)?.image( { result in
                switch result {
                case .success(let newImage): thumbnailImage = newImage
                default: break
                }
            })
            
            expect(thumbnailImage).toEventually(beNil())
        }
    }
}
