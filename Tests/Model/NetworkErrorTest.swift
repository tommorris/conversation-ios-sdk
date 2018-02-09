//
//  NetworkErrorTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 29/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import Alamofire
@testable import NexmoConversation

internal class NetworkErrorTest: QuickSpec {

    // MARK:
    // MARK: Test

    override func spec() {
        it("create error fails with bad JSON") {
            do {
                let data = try JSONSerialization.data(withJSONObject: [:])
                let response = DataResponse<Any>(request: nil, response: nil, data: data, result: Result.failure(ConversationClient.Errors.networking))

                expect(try? NetworkError(from: response)).to(beNil())
            } catch {
                fail()
            }
        }
        
        it("create error passes") {
            do {
                let error = ["code": "code", "description": "description"]
                let data = try JSONSerialization.data(withJSONObject: error)
                guard let url = URL(string: "www.nexmo.com") else { return fail() }
                let response = HTTPURLResponse.init(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [:])
                let dataResponse = DataResponse<Any>(request: nil, response: response, data: data, result: Result.failure(ConversationClient.Errors.networking))
                
                expect(try? NetworkError(from: dataResponse)).toNot(beNil())
            } catch {
                fail()
            }
        }

        it("uses stock title for creating a network error") {
            let response = DefaultDataResponse(request: nil, response: nil, data: nil, error: nil)
            let error = NetworkError(from: response)

            expect(error.type) == ""
            expect(error.localizedDescription) == ""
            expect(error.requestURL).to(beNil())
            expect(error.code).to(beNil())
        }

        it("creates a network error") {
            do {
                let data = try JSONSerialization.data(withJSONObject: [:])
                guard let url = URL(string: "https://nexmo.com") else { return fail() }
                let request = URLRequest(url: url)
                let httpResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
                let response = DefaultDataResponse(request: request, response: httpResponse, data: data, error: nil)
                let error = NetworkError(type: "title", localizedDescription: "description", from: response)

                expect(error.type) == "title"
                expect(error.errorDescription) == "description"
                expect(error.requestURL).toNot(beNil())
                expect(error.code).toNot(beNil())
            } catch {
                fail()
            }
        }
    }
}
