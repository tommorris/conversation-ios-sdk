//
//  ImageTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 28/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import UIKit
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class ImageTest: QuickSpec {
    
    // MARK: 
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
    }
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        it("Create a uploaded image model") {
            // model
            let response = self.json(path: .uploadedImage)
            
            guard let model = Event.Body.Image(json: response) else { return fail() }
            
            guard let original = model.image(for: .original) else { return fail() }
            guard let medium = model.image(for: .medium) else { return fail() }
            guard let thumbnail = model.image(for: .thumbnail) else { return fail() }

            // test
            expect(model.id).toNot(beNil())
            
            [thumbnail, original, medium].forEach { image in
                switch image {
                case .link(let id, let url, _, let size):
                    expect(id).notTo(beNil())
                    expect(url.absoluteString.isEmpty) == false
                    expect(size) > 1
                }
            }
        }
        
        it("fails with empty json") {
            expect(Event.Body.Image(json: [:])).to(beNil())
        }
        
        it("fails with empty image json") {
            expect(Event.Body.Image.Metadata.create(json: [:])).to(beNil())
        }
        
        it("fails with bad image json") {
            expect(Event.Body.Image.Metadata.create(json: ["type": "original"])).to(beNil())
        }
        
        it("fails with bad json image data") {
            let model = Event.Body.Image(json: ["id": ""])
            
            expect((model?.json["original"] as? [String: Any])?["url"]).to(beNil())
        }
        
        it("successfully determines two identical images are the same") {
            // test
            let response = self.json(path: .uploadedImage)
            
            guard let image1 = Event.Body.Image(json: response) else { return fail() }
            guard let image2 = Event.Body.Image(json: response) else { return fail() }
        
            guard let original1 = image1.image(for: .original) else { return fail() }
            guard let medium1 = image1.image(for: .medium) else { return fail() }
            guard let thumbnail1 = image1.image(for: .thumbnail) else { return fail() }
            
            guard let original2 = image2.image(for: .original) else { return fail() }
            guard let medium2 = image2.image(for: .medium) else { return fail() }
            guard let thumbnail2 = image2.image(for: .thumbnail) else { return fail() }
            
            let sequence1 = [thumbnail1, original1, medium1]
            let sequence2 = [thumbnail2, original2, medium2]
            
            for (index, image) in sequence1.enumerated() {
                let image2 = sequence2[index]
                expect(image2).toNot(beNil())
                expect(image).toEventually(equal(image2))
            }
        }
        
        it("successfully determines two different images are not equal") {
            // test
            let response = self.json(path: .uploadedImage)
            let response2 = self.json(path: .uploadedImageOther)
            
            guard let image1 = Event.Body.Image(json: response) else { return fail() }
            guard let image2 = Event.Body.Image(json: response2) else { return fail() }
            
            guard let original1 = image1.image(for: .original) else { return fail() }
            guard let medium1 = image1.image(for: .medium) else { return fail() }
            guard let thumbnail1 = image1.image(for: .thumbnail) else { return fail() }
            
            guard let original2 = image2.image(for: .original) else { return fail() }
            guard let medium2 = image2.image(for: .medium) else { return fail() }
            guard let thumbnail2 = image2.image(for: .thumbnail) else { return fail() }
            
            let sequence1 = [thumbnail1, original1, medium1]
            let sequence2 = [thumbnail2, original2, medium2]
            
            for (index, image) in sequence1.enumerated() {
                let image2 = sequence2[index]
                expect(image2).toNot(beNil())
                expect(image).toEventuallyNot(equal(image2))
            }
        }
        
        it("creates draft image no images") {
            let model = Event.Body.Image(id: "12345", path: "some url", size: 0)
            
            expect(model).toNot(beNil())
            expect(model.id.isEmpty) == false
            expect(model.image(for: .thumbnail)).toNot(beNil())
        }
        
        it("creates draft image with one images") {
            let path = NSTemporaryDirectory()
            
            let model = Event.Body.Image(id: "12345", path: path, size: 0)
            
            expect(model).toNot(beNil())
            expect(model.id.isEmpty) == false
            expect(model.image(for: .thumbnail)).toNot(beNil())
        }
    }
}
