//
//  ImageEventTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 05/01/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class ImageEventTest: QuickSpec {
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("creates a image event with event model") {
            let image = self.json(path: .uploadedImage)
            let event = Event(cid: "con-123", type: .image, memberId: "mem-123", body: image)

            let imageEvent = ImageEvent(conversationUuid: "con-123", event: event, seen: false)

            expect(imageEvent).toNot(beNil())
        }
        
        it("creates a image event with db event model") {
            let event = DBEvent(
                conversationUuid: "con-123",
                event: Event(cid: "con-123", type: .text, memberId: "mem-123"),
                seen: false
            )
            
            let imageEvent = ImageEvent(data: event)
            
            expect(imageEvent).toNot(beNil())
        }
        
        it("fetches a image") {
            guard let url = URL(string: "http://localhost:3031/v1/files/a5215191-f00a-4791-8b9e-6f51b6d82537") else { return fail() }
            let request = URLRequest(url: url)
            self.stub(file: .nexmo, request: request, statusCode: 201)
            
            let json = self.json(path: .uploadedImage)
            let event = Event(cid: "con-123", type: .image, memberId: "mem-123", body: json)
            let imageEvent = ImageEvent(conversationUuid: "con-123", event: event, seen: false)
            
            var image: UIImage?
            
            imageEvent.image { result in
                switch result {
                case .success(let newImage): image = newImage
                default: fail()
                }
            }
            
            expect(image).toEventuallyNot(beNil())
        }
        
        it("fails to fetch a image with bad data") {
            self.stubServerError(request: MediaRouter.download(url: "http://localhost:3031/v1/files/be2f3a65-dac6-4be2-a7ac-b03048bbd74a").urlRequest)

            let json = self.json(path: .uploadedImage)
            let event = Event(cid: "con-123", type: .image, memberId: "mem-123", body: json)
            let imageEvent = ImageEvent(conversationUuid: "con-123", event: event, seen: false)
            
            var hasFailed = false
            
            imageEvent.image(for: .medium, { result in
                switch result {
                case .success: fail()
                default: hasFailed = true
                }
            })
            
            expect(hasFailed).toEventually(beTrue())
        }
        
        it("reads the file size sent from IPS") {
            let json = self.json(path: .uploadedImage)
            let event = Event(cid: "con-123", type: .image, memberId: "mem-123", body: json)
            let imageEvent = ImageEvent(conversationUuid: "con-123", event: event, seen: false)
            
            expect(imageEvent.size(for: .thumbnail)) == 873
            expect(imageEvent.size(for: .medium)) == 3247
            expect(imageEvent.size(for: .original)) == 9529
        }
        
        it("fails to reads file size sent from IPS") {
            let event = Event(cid: "con-123", type: .image, memberId: "mem-123", body: [:])
            let imageEvent = ImageEvent(conversationUuid: "con-123", event: event, seen: false)
            
            expect(imageEvent.size(for: .thumbnail)).to(beNil())
            expect(imageEvent.size(for: .medium)).to(beNil())
            expect(imageEvent.size(for: .original)).to(beNil())
        }
    }
}
