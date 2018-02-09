//
//  DownloadQueueTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 18/08/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import RxSwift
import Quick
import Nimble
import Mockingjay
@testable import NexmoConversation

internal class DownloadQueueTest: QuickSpec {

    let downloadQueue = DownloadQueue()

    // MARK:
    // MARK: Test

    override func spec() {
        it("compares state") {
            expect(DownloadQueue.State.inactive) == DownloadQueue.State.inactive
            expect(DownloadQueue.State.active(0)) == DownloadQueue.State.active(0)
            expect(DownloadQueue.State.active(0)) == DownloadQueue.State.active(1)
        }

        it("compares state for not equal") {
            expect(DownloadQueue.State.inactive) != DownloadQueue.State.active(0)
            expect(DownloadQueue.State.inactive) != DownloadQueue.State.active(10)
        }

        it("check queue setup") {
            expect(DownloadQueue.maximumParallelTasks) == 3
            expect(DownloadQueue.maximumRetries) == 3
        }

        it("increases state count by 1") {
            let task = Observable<Bool>.just(true)

            var didSentToActive: Bool = false

            _ = self.downloadQueue.state.asDriver().asObservable().subscribe(onNext: { state in
                switch state {
                case .active(let i) where i == 1: didSentToActive = true
                default: break
                }
            })

            expect(self.downloadQueue.state.value) == DownloadQueue.QueueState.inactive

            _ = task
                .observeOn(self.downloadQueue.queue)
                .subscribeOn(self.downloadQueue.queue)
                .subscribe()

            expect(self.downloadQueue.queue).toNot(beNil())
            expect(didSentToActive).toEventually(beTrue())
            expect(self.downloadQueue.state.value).toEventually(equal(DownloadQueue.QueueState.inactive))
        }
    }
}
