//
//  DiskCacheTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 16/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class DiskCacheTest: QuickSpec {

    lazy var cache: DiskCache = DiskCache(
        with: ("\(NSHomeDirectory())/\(Constants.Keys.nexmoDictionary)/Files")
    )

    // MARK:
    // MARK: Test

    override func spec() {
        it("create disk cache object") {
            expect(self.cache.directory) == "\(NSHomeDirectory())/\(Constants.Keys.nexmoDictionary)/Files"
        }

        it("set a image object") {
            guard let url = Bundle(for: type(of: self)).url(forResource: AssetsTest.nexmo.path, withExtension: nil),
                let data = try? Data(contentsOf: url) else {
                return fail()
            }

            var image: Data?

            self.cache.set(key: "urlLink1", value: data)

            self.cache.get("urlLink1", { (newImage: Data?) in
                image = newImage
            })

            expect(image).toEventuallyNot(beNil())
            expect(image.isEmpty()).toEventually(beFalse())

            let isImageValid: () -> UIImage? = {
                guard let image = image else { return nil }

                return UIImage(data: image)
            }

            expect(isImageValid).toEventuallyNot(beNil())
            expect(self.cache.fileExist(at: "urlLink1")) == true
        }

        it("set a string object") {
            var stringValue: String?

            self.cache.set(key: "urlLink2", value: "my string value")

            self.cache.get("urlLink2", { (newString: String?) in
                stringValue = newString
            })

            expect(stringValue).toEventuallyNot(beNil())
            expect(stringValue).toEventually(equal("my string value"))
            expect(stringValue.isEmpty()).toEventually(beFalse())
        }

        it("removes one value") {
            expect(self.cache.contents.count == 2).toEventually(beTrue())

            self.cache.remove(key: "urlLink1")

            expect(self.cache.contents.count == 1).toEventually(beTrue())
        }

        it("removes all value in cache") {
            self.cache.removeAll()

            expect(self.cache.contents.isEmpty).toEventually(beTrue(), timeout: 5)
        }
    }
}
