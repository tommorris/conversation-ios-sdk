//
//  MediaRouterTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 20/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class MediaRouterTest: QuickSpec {

    // MARK:
    // MARK: Test

    override func spec() {
        it("it creates a url without slash at the end of the url") {
            let url = MediaRouter.download(url: "https://nexmo.com/123").urlRequest?.url

            expect(url?.absoluteString.hasSuffix("/")) == false
        }
    }
}
