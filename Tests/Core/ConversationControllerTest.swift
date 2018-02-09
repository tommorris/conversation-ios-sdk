//
//  ConversationControllerTest.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 14/11/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Mockingjay
import RxSwift
import RxTest
import RxBlocking
@testable import NexmoConversation

internal class ConversationControllerTest: QuickSpec {

    lazy var account: AccountController = { return ConversationClient.instance.account }()

    lazy var conversation: ConversationController = {
        ConversationClient.instance.account.state.value = .loggedIn(Session(id: "s-123", userId: "usr-123", name: "name"))

        return ConversationClient.instance.conversation
    }()
    
    // MARK:
    // MARK: Test
    
    override func spec() {
        
        // MARK:
        // MARK: Test
        
        it("creates a new joined conversation") {
            self.account.userId = "usr-3"
            _ = try? ConversationClient.instance.storage.databaseManager.user.insert(SimpleMockDatabase().user3)
            
            let model = ConversationService.CreateConversation(name: "test")
            
            let join = ConversationController.JoinConversation(
                userId: "USR-13c9bd1d-cae0-410b-a552-614029377f25",
                memberId: "MEM-48495986-45aa-45fe-ad92-e546fba87b87"
            )
            
            self.stub(file: .liteConversation, request: ConversationRouter.create(model: model.json).urlRequest)
            self.stub(file: .fullConversation, request: ConversationRouter.conversation(id: "CON-075e4e6a-d168-4c10-a29a-ccb29058c27c").urlRequest)
            self.stub(file: .joinConversation, request: ConversationRouter.join(
                uuid: "CON-075e4e6a-d168-4c10-a29a-ccb29058c27c",
                parameters: join.json
                ).urlRequest
            )
            
            var conversation: Conversation?
            
            do {
                conversation = try self.conversation.new("test", withJoin: true).toBlocking().first()
            } catch let error {
                fail(error.localizedDescription)
            }
            
            expect(conversation?.uuid).toEventuallyNot(beNil())
        }

        it("fails to create conversation without a user id") {
            // Bug in simulator where it caches value in memory
            UserDefaults.standard.set(nil, forKey: "username")
            UserDefaults.standard.synchronize()

            self.account.userId = nil

            var error: ConversationClient.Errors?

            UserDefaults.standard.synchronize()

            _ = self.conversation.new("test").subscribe(onNext: { _ in
                fail()
            }, onError: { newError in
                error = newError as? ConversationClient.Errors
            })

            expect(error).toEventually(equal(ConversationClient.Errors.userNotInCorrectState))
            expect(self.account.userId).to(beNil())
        }

        it("fails to create a new non-joined conversation") {
            self.account.userId = "usr-3"
            _ = try? ConversationClient.instance.storage.databaseManager.user.insert(SimpleMockDatabase().user3)
            
            let join = ConversationController.JoinConversation(
                userId: "USR-13c9bd1d-cae0-410b-a552-614029377f25",
                memberId: "MEM-48495986-45aa-45fe-ad92-e546fba87b87"
            )
            
            let model = ConversationService.CreateConversation(name: "test")
            
            self.stub(file: .liteConversation, request: ConversationRouter.create(model: model.json).urlRequest)
            self.stub(file: .fullConversation, request: ConversationRouter.conversation(id: "CON-075e4e6a-d168-4c10-a29a-ccb29058c27c").urlRequest)
            self.stub(file: .joinConversation, request: ConversationRouter.join(
                uuid: "CON-075e4e6a-d168-4c10-a29a-ccb29058c27c",
                parameters: join.json
                ).urlRequest
            )
            
            var receivedConversation = false
            var expected = false
            
            _ = self.conversation.new("test", withJoin: false).subscribe(onNext: { _ in
                receivedConversation = true
            }, onCompleted: {
                expected = true
            })

            expect(expected).toEventually(beTrue(), timeout: 5)
            expect(receivedConversation).toEventuallyNot(beTrue(), timeout: 5)
        }

        it("fails to create a new joined conversation with returned error") {
            let model = ConversationService.CreateConversation(name: "test")
            
            self.stubServerError(request: ConversationRouter.create(model: model.json).urlRequest)
            
            var errorResponse: Error?
            
            _ = self.conversation.new("test", withJoin: true).subscribe(onError: { error in
                errorResponse = error
            })
            
            expect(errorResponse).toEventuallyNot(beNil(), timeout: 5)
        }
        
        it("fails to create a new joined conversation with bad data") {
            let model = ConversationService.CreateConversation(name: "test")
            
            self.stub(json: [:], request: ConversationRouter.create(model: model.json).urlRequest)
            
            var errorResponse: Error?
            
            _ = self.conversation.new("test", withJoin: true).subscribe(onError: { error in
                errorResponse = error
            })
            
            expect(errorResponse).toEventuallyNot(beNil(), timeout: 5)
        }
        
        it("join a conversation") {
            let model = ConversationController.JoinConversation(
                userId: "USR-13c9bd1d-cae0-410b-a552-614029377f25",
                memberId: "MEM-48495986-45aa-45fe-ad92-e546fba87b87"
            )
            
            self.stub(file: .joinConversation, request: ConversationRouter.join(
                uuid: "CON-19da5cd2-388d-40f4-909d-431f23572cfa",
                parameters: model.json
                ).urlRequest
            )
            
            var statusResponse: MemberModel.State?
            
            _ = self.conversation.join(model, forUUID: "CON-19da5cd2-388d-40f4-909d-431f23572cfa")
                .subscribe(onNext: { status in
                statusResponse = status
                }, onError: { _ in
                    fail()
                })
            
            expect(statusResponse?.hashValue).toEventually(equal(MemberModel.State.joined.hashValue))
        }
        
        it("fail to join a conversation") {
            let model = ConversationController.JoinConversation(
                userId: "USR-13c9bd1d-cae0-410b-a552-614029377f25",
                memberId: "MEM-48495986-45aa-45fe-ad92-e546fba87b87"
            )
            
            self.stubServerError(request: ConversationRouter.join(
                uuid: "CON-19da5cd2-388d-40f4-909d-431f23572cfa",
                parameters: model.json
                ).urlRequest
            )
            
            var errorResponse: Error?
            
            _ = self.conversation.join(model, forUUID: "CON-19da5cd2-388d-40f4-909d-431f23572cfa")
                .subscribe(onError: { error in
                    errorResponse = error
                })
            
            expect(errorResponse).toEventuallyNot(beNil())
        }
        
        it("fail to join a conversation with bad response") {
            let model = ConversationController.JoinConversation(
                userId: "USR-13c9bd1d-cae0-410b-a552-614029377f25",
                memberId: "MEM-48495986-45aa-45fe-ad92-e546fba87b87"
            )
            
            self.stub(json: [:], request: ConversationRouter.join(
                uuid: "CON-19da5cd2-388d-40f4-909d-431f23572cfa",
                parameters: model.json
                ).urlRequest
            )
            
            var errorResponse: Error?
            
            _ = self.conversation.join(model, forUUID: "CON-19da5cd2-388d-40f4-909d-431f23572cfa").subscribe(onError: { error in
                errorResponse = error
            })
            
            expect(errorResponse).toEventuallyNot(beNil())
        }
        
        it("start a new conversation") {
            self.account.userId = "usr-3"
            _ = try? ConversationClient.instance.storage.databaseManager.user.insert(SimpleMockDatabase().user3)

            let join = ConversationController.JoinConversation(
                userId: "USR-13c9bd1d-cae0-410b-a552-614029377f25",
                memberId: "MEM-48495986-45aa-45fe-ad92-e546fba87b87"
            )
            
            let model = ConversationService.CreateConversation(name: "test")

            self.stub(file: .liteConversation, request: ConversationRouter.create(model: model.json).urlRequest)
            self.stub(file: .fullConversation, request: ConversationRouter.conversation(id: "CON-075e4e6a-d168-4c10-a29a-ccb29058c27c").urlRequest)
            self.stub(file: .joinConversation, request: ConversationRouter.join(
                uuid: "CON-075e4e6a-d168-4c10-a29a-ccb29058c27c",
                parameters: join.json
                ).urlRequest
            )

            var conversation: Conversation?
            
            do {
                conversation = try self.conversation.new("test", withJoin: true).toBlocking().first()
            } catch let error {
                fail(error.localizedDescription)
            }

            expect(conversation?.uuid).toEventuallyNot(beNil())
        }
        
        it("fetches all conversations") {
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

            if let models: [ConversationController.LiteConversation]? = try? self.conversation.all().toBlocking().first() {
                expect(models?.isEmpty) == false
                expect(models?.count) == 837
            } else {
                fail()
            }
        }
        
        it("fails to fetch all conversations") {
            self.stubServerError(request: ConversationRouter.all(from: 0).urlRequest)
            
            let request: [ConversationController.LiteConversation]?? = try? self.conversation.all().toBlocking().first()
            
            expect(request??.isEmpty).to(beNil())
        }
        
        it("fails to fetch all conversations with bad response") {
            self.stub(json: [:], request: ConversationRouter.all(from: 0).urlRequest)
            
            let request: [ConversationController.LiteConversation]?? = try? self.conversation.all().toBlocking().first()
            
            expect(request??.isEmpty).to(beNil())
        }
        
        it("fetches user conversations") {
            self.stub(file: .conversations, request: ConversationRouter.allUser(id: "id").urlRequest)
            
            if let request: [ConversationPreviewModel]? = try? self.conversation.all(with: "id").toBlocking().first() {
               expect(request?.isEmpty) == false
            } else {
                fail()
            }
        }
        
        it("fails to fetches user conversations") {
            self.stubServerError(request: ConversationRouter.allUser(id: "id").urlRequest)
            
            let request: [ConversationPreviewModel]?? = try? self.conversation.all(with: "id").toBlocking().first()
            
            expect(request??.isEmpty).to(beNil())
        }
        
        it("fails to fetches user conversations with bad response") {
            self.stub(json: [:], request: ConversationRouter.allUser(id: "id").urlRequest)
            
            let request: [ConversationPreviewModel]?? = try? self.conversation.all(with: "id").toBlocking().first()
            
            expect(request??.isEmpty).to(beNil())
        }

        it("fetches one conversation") {
            self.stub(file: .fullConversation, request: ConversationRouter.conversation(id: "con-123").urlRequest)
            
            let conversation: Conversation?? = try? self.conversation.conversation(with: "con-123")
                .toBlocking()
                .first()
            
            expect(conversation??.uuid.isEmpty).toEventually(beFalse())
            expect(conversation??.name.isEmpty).to(beFalse())
        }
        
        it("fails to fetch one conversation with bad network") {
            self.stubServerError(request: ConversationRouter.conversation(id: "con-123").urlRequest)
            
            let conversation: Conversation?? = try? self.conversation.conversation(with: "con-123")
                .toBlocking()
                .first()
            
            expect(conversation).to(beNil())
        }
        
        it("fails to fetch one conversation with bad network with bad response") {
            self.stub(json: [:], request: ConversationRouter.conversation(id: "con-123").urlRequest)
            
            let conversation: Conversation?? = try? self.conversation.conversation(with: "con-123")
                .toBlocking()
                .first()
            
            expect(conversation).to(beNil())
        }
        
        it("fails to fetch one conversation with bad network with no members") {
            var json = self.json(path: .fullConversation)
            json["members"] = []
            
            self.stub(json: json, request: ConversationRouter.conversation(id: "con-123").urlRequest)
            
            let conversation: Conversation?? = try? self.conversation.conversation(with: "con-123")
                .toBlocking()
                .first()
            
            expect(conversation).to(beNil())
        }

        it("gets 404 for conversation not found") {
            self.stub(
                file: .conversationNotFound,
                request: ConversationRouter.conversation(id: "con-123").urlRequest,
                statusCode: 404
            )

            var error: NetworkError?

            _ = self.conversation.conversation(with: "con-123").subscribe(onError: { newError in
                error = newError as? NetworkError
            })

            expect(error?.type).toEventually(equal(NetworkError.Code.Conversation.notFound.rawValue))
        }

        it("gets 400 for already joined conversation") {
            let model = ConversationController.JoinConversation(userId: "usr-123", memberId: "mem-123")

            self.stub(
                file: .memberAlreadyJoinedError,
                request: ConversationRouter.join(uuid: "con-123", parameters: model.json).urlRequest,
                statusCode: 400
            )

            var error: NetworkError?

            _ = self.conversation.join(model, forUUID: "con-123").subscribe(onError: { newError in
                error = newError as? NetworkError
            })

            expect(error?.type).toEventually(equal(NetworkError.Code.Conversation.alreadyJoined.rawValue))
        }
    }
}
