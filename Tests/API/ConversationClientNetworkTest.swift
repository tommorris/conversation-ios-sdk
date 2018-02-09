//
//  ConversationClientTest+Network.swift
//  NexmoConversation
//
//  Created by shams ahmed on 13/06/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxTest
import RxBlocking

@testable import NexmoConversation

internal class ConversationClientNetworkTest: QuickSpec {
    
    let client = ConversationClient.instance
    
    lazy var conversation: ConversationController = {
        ConversationClient.instance.account.state.value = .loggedIn(Session(id: "s-123", userId: "usr-123", name: "name"))
        
        return ConversationClient.instance.conversation
    }()
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        beforeSuite {
            self.client.addAuthorization(with: "token")
        }

        it("reports an error for 300 status code") {
            let stub = self.stub(
                file: .errorNotFound,
                request: ConversationRouter.all(from: 0).urlRequest,
                statusCode: 300
            )
            
            self.client.addAuthorization(with: "token")
            
            self.client.conversation.all().subscribe().disposed(by: self.client.disposeBag)
            
            var error: NetworkErrorProtocol?
            
            do {
                error = try self.client.unhandledError.toBlocking().first()
            } catch let newError {
                fail(newError.localizedDescription)
            }
            
            expect(error?.code) == 300
            expect(error?.localizedDescription) == "some description"
            expect(error?.requestURL?.count).to(beGreaterThan(5))
            
            self.removeStub(stub)
            self.removeAllStubs()
        }
        
        it("reports an error for 400 client side status code") {
            self.removeAllStubs()
            
            self.stub(file: .errorNotFound, request: ConversationRouter.all(from: 0).urlRequest, statusCode: 400)
            
            _ = self.client.conversation.all().subscribe()
            
            do {
                let error = try self.client.unhandledError.toBlocking().first()
                
                expect(error?.code) == 400
                expect(error?.localizedDescription) == "some description"
                expect(error?.requestURL?.count).to(beGreaterThan(5))
            } catch let error {
                fail(error.localizedDescription)
            }
        }
        
        it("reports an error for 500 server side status code") {
            self.stubServerError(request: ConversationRouter.all(from: 0).urlRequest)
            
            var error: NetworkErrorProtocol?
            
            _ = self.client.conversation.all().subscribe().disposed(by: self.client.disposeBag)
            
            _ = self.client.unhandledError.subscribe(onNext: { newError in
                error = newError as? NetworkErrorProtocol
            }).disposed(by: self.client.disposeBag)
            
            expect(error?.code).toEventually(equal(500), timeout: 10)
            expect(error?.type) == "Response status code was unacceptable: 500."
        }
        
        it("doesn't report an error for 200 status code and json data is parsed") {
            self.stub(file: .allWithoutUserId1, request: ConversationRouter.all(from: 0).urlRequest)
            self.stub(file: .allWithoutUserId2, request: ConversationRouter.all(from: 100).urlRequest)
            self.stub(file: .allWithoutUserId3, request: ConversationRouter.all(from: 200).urlRequest)
            self.stub(file: .allWithoutUserId4, request: ConversationRouter.all(from: 300).urlRequest)
            self.stub(file: .allWithoutUserId5, request: ConversationRouter.all(from: 400).urlRequest)
            self.stub(file: .allWithoutUserId6, request: ConversationRouter.all(from: 499).urlRequest)
            self.stub(file: .allWithoutUserId7, request: ConversationRouter.all(from: 597).urlRequest)
            self.stub(file: .allWithoutUserId8, request: ConversationRouter.all(from: 696).urlRequest)
            self.stub(file: .allWithoutUserId9, request: ConversationRouter.all(from: 792).urlRequest)
            self.stub(file: .allWithoutUserId10, request: ConversationRouter.all(from: 793).urlRequest)
            self.stub(file: .allWithoutUserId10, request: ConversationRouter.all(from: 836).urlRequest)

            if let request: [ConversationController.LiteConversation]? = try? self.conversation.all().toBlocking().first() {
                expect(request?.isEmpty) == false
            } else {
                fail()
            }
        }
    }
}
