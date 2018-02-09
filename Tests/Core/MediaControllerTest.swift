//
//  MediaControllerTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 21/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation
import RxSwift
import RxTest
import RxBlocking

internal class MediaControllerTest: QuickSpec {

    lazy var mediaController: MediaController = {
        let network = NetworkController(token: "token")

        return MediaController(network: network)
    }()

    // MARK:
    // MARK: Box

    internal struct BoxTest: RawDecodable {

        var data: Data?

        internal init?(_ data: Data) {
            self.data = data
        }
    }

    internal struct BadBoxTest: RawDecodable {

        var data: Data?

        internal init?(_ data: Data) {
            return nil
        }
    }

    // MARK:
    // MARK: Test

    override func spec() {
        it("fetches a image object") {
            self.stub(file: .nexmo, request: MediaRouter.download(url: "http://localhost:3031/v1/files/794108f1-d62d-4205-97d9-a9a611e051c0").urlRequest)

            let json = self.json(path: .uploadedImage)
            guard let image = Event.Body.Image(json: json), let type = image.image(for: .original) else { return fail() }

            guard case .link(_, let url, _, _) = type else { return fail() }
            guard let model: BoxTest? = try? self.mediaController.download(at: url.absoluteString).toBlocking().first() else { return fail() }

            expect(model?.data).toNot(beNil())
            expect(model?.data.isEmpty()) == false
            expect(model?.data?.count) > 1000

            let hasImage: () -> UIImage? = {
                guard let data = model?.data else { return nil }

                return UIImage(data: data)
            }

            expect(hasImage).toNot(beNil())
        }

        it("fails to fetch image object") {
            self.stubServerError(request: MediaRouter.download(url: "http://localhost:3031/v1/files/794108f1-d62d-4205-97d9-a9a611e051c0").urlRequest)
            self.stubServerError(request: MediaRouter.download(url: "http://localhost:3031/v1/files/be2f3a65-dac6-4be2-a7ac-b03048bbd74a").urlRequest)

            let json = self.json(path: .uploadedImage)
            guard let image = Event.Body.Image(json: json), let type = image.image(for: .original) else { return fail() }

            guard case .link(_, let url, _, _) = type else { return fail() }

            var error: Error?

            let download: Single<BoxTest> = self.mediaController.download(at: url.absoluteString)

            _ = download.subscribe(onError: { error = $0 })

            expect(error).toEventuallyNot(beNil())
        }

        it("fails to fetch image object with bad data") {
            self.stub(file: .nexmo, request: MediaRouter.download(url: "http://localhost:3031/v1/files/794108f1-d62d-4205-97d9-a9a611e051c0").urlRequest)
            self.stub(file: .nexmo, request: MediaRouter.download(url: "http://localhost:3031/v1/files/be2f3a65-dac6-4be2-a7ac-b03048bbd74a").urlRequest)

            let json = self.json(path: .uploadedImage)
            guard let image = Event.Body.Image(json: json), let type = image.image(for: .original) else { return fail() }

            guard case .link(_, let url, _, _) = type else { return fail() }

            var error: Error?

            let download: Single<BadBoxTest> = self.mediaController.download(at: url.absoluteString)

            _ = download.subscribe(onError: { error = $0 })

            expect(error).toEventuallyNot(beNil())
        }
    }
}
