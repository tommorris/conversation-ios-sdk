//
//  MediaCachingTest.swift
//  NexmoConversation
//
//  Created by Ashley Arthur on 18/09/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Mockingjay
import NexmoConversation

class MediaCacheTest: QuickSpec {
    
    let client = ConversationClient.instance
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 5
        Nimble.AsyncDefaults.PollInterval = 1
        
        var imgEvent: ImageEvent?
        var imageDownloadCount = 0
        
        beforeEach {
            // listen for image download requests
            self.stub(http(.get, uri: "/image")) { (request: URLRequest) -> Mockingjay.Response in
                imageDownloadCount += 1
                
                guard let url = request.url,
                    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
                    let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil),
                    let data = UIImagePNGRepresentation(image) else {
                    return .failure(NSError())
                }
                
                return .success(response, .content(data))
            }
            
            // Setup Image Event for tests
            guard let token = ["template": "event-list-singleimage"].JSONString else { return fail() }
            
            BasicOperations.login(with: self.client, using: token)
            
            guard let conv = self.client.conversation.conversations.first,
                let event = conv.events.first(where: { ($0 as? ImageEvent) != nil }),
                let img = event as? ImageEvent else {
                return fail()
            }
            
            imgEvent = img
        }
        
        afterEach {
            BasicOperations.logout(client: self.client)
            
            imgEvent = nil
            imageDownloadCount = 0
        }
        
        context("Initial access of received ImageEvent Image") {
            it("should send network request as no cache exists") {
                guard let imgEvent = imgEvent else { return fail() }
                
                var image: UIImage?
                
                imgEvent.image { result in
                    switch result {
                    case .success(let i): image = i
                    default: fail()
                    }
                }
                
                expect(image).toEventuallyNot(beNil())
                expect(imageDownloadCount).to(equal(1))
            }
        }
        
        context("Subsequent access of ImageEvent Image") {
            it("should retrieve image from cache and skip network request") {
                guard let imgEvent = imgEvent else { return fail() }
                
                for _ in 0...3 {
                    var image: UIImage?
                    
                    imgEvent.image { result in
                        switch result {
                        case .success(let i): image = i
                        default: fail()
                        }
                    }
                    
                    expect(image).toEventuallyNot(beNil())
                }
                
                expect(imageDownloadCount).to(equal(1))
            }
        }
        
        context("Initial Access of Original size Image") {
            it("should require a new network request") {
                guard let imgEvent = imgEvent else { return fail() }
                
                var image: UIImage?
                
                imgEvent.image(for: .original) { result in
                    switch result {
                    case .success(let i): image = i
                    default: fail()
                    }
                }
                
                expect(image).toEventuallyNot(beNil())
                expect(imageDownloadCount).to(equal(2))
            }
        }
        
        context("Subsequent access of Original size Image") {
            it("should retrieve image from cache and skip network request") {
                guard let imgEvent = imgEvent else { return fail() }
                
                for _ in 0...3 {
                    var image: UIImage?
                    
                    imgEvent.image(for: .original) { result in
                        switch result {
                        case .success(let i): image = i
                        default: fail()
                        }
                    }
                    
                    expect(image).toEventuallyNot(beNil())
                }
                
                expect(imageDownloadCount).to(equal(2))
            }
        }
    }
}
