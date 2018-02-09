//
//  RequestTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 31/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class RequestTest: QuickSpec {

    let client = NetworkController(token: "token")

    // MARK:
    // MARK: Test

    override func spec() {
        it("complete uploading image with 100% progress count") {
            self.client.token = "token"

            // parameter
            guard let body = Event.Body.Image(json: self.json(path: .uploadedImage))?.json else { return fail() }

            let event = SendEvent(
                conversationId: "CON-0673a8d7-721c-4c68-8374-cbb080065b00",
                from: "MEM-f9b7175c-1ac5-422f-b332-d206974626c4",
                representations: body,
                tid: "1234"
            )

            guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
            guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }

            let parameters: IPSService.UploadImageParameter = (
                image: data,
                size: (originalRatio: nil, mediumRatio: nil, thumbnailRatio: nil)
            )

            var request: Request?

            // stub
            self.stub(file: .uploadedImage, request: IPSRouter.upload.urlRequest)
            self.stub(file: .sendImageMessage, request: EventRouter.send(event: event).urlRequest)

            // request
            self.client.eventService.upload(
                image: parameters,
                conversationId: event.conversationId, 
                fromId: event.from,
                tid: "1234",
                success: { _ in },
                failure: { _ in },
                progress: { newRequest in
                    request = newRequest

                    newRequest.progress { _ in }
                }
            )

            // test
            expect(request?.state.fractionCompleted).toEventually(beGreaterThanOrEqualTo(0))
        }

        it("completes sending a request with 100% progress") {
            // parameter
            let event = SendEvent(
                conversationId: "CON-0673a8d7-721c-4c68-8374-cbb080065b00",
                from: "MEM-f9b7175c-1ac5-422f-b332-d206974626c4",
                text: "hello from: \(Date())",
                tid: "1234")

            // stub
            self.stub(file: .sendImageMessage, request: EventRouter.send(event: event).urlRequest)

            var complete = false

            // request
            let request = self.client.eventService.send(event: event, success: { _ in complete = true }, failure: { _ in })

            request.progress { _ in }

            // test
            expect(request.state.fractionCompleted).toEventually(beGreaterThanOrEqualTo(0))
            expect(complete).toEventually(beTrue())
        }

        it("cancels upload image request") {
            self.client.token = "token"

            // parameter
            guard let body = Event.Body.Image(json: self.json(path: .uploadedImage))?.json else { return fail() }

            let event = SendEvent(
                conversationId: "CON-0673a8d7-721c-4c68-8374-cbb080065b00",
                from: "MEM-f9b7175c-1ac5-422f-b332-d206974626c4",
                representations: body,
                tid: "1234"
            )

            guard let image = UIImage(named: AssetsTest.nexmo.path, in: Bundle(for: type(of: self)), compatibleWith: nil) else { return fail() }
            guard let data = UIImageJPEGRepresentation(image, 0.75) else { return fail() }

            let parameters: IPSService.UploadImageParameter = (
                image: data,
                size: (originalRatio: nil, mediumRatio: nil, thumbnailRatio: nil)
            )

            var request: Request?

            // request
            self.client.eventService.upload(
                image: parameters,
                conversationId: event.conversationId,
                fromId: event.from,
                tid: "1234",
                success: { _ in },
                failure: { _ in },
                progress: { newRequest in
                    request = newRequest

                    newRequest.progress { _ in }
                }
            )

            // test
            expect(request?.cancel()).toEventually(beTrue())
        }

        it("cancel sending a request with 100% progress") {
            // parameter
            let event = SendEvent(
                conversationId: "CON-0673a8d7-721c-4c68-8374-cbb080065b00",
                from: "MEM-f9b7175c-1ac5-422f-b332-d206974626c4",
                text: "hello from: \(Date())",
                tid: "1234")

            // request
            let request = self.client.eventService.send(event: event, success: { _ in }, failure: { _ in })
            
            // test
            expect(request.cancel()).toEventually(beTrue())
        }
    }
}
