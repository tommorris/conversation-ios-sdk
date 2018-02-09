//
//  E2ETestManager.swift
//  NexmoConversationE2ETests
//
//  Created by Ivan on 05/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import Alamofire
import Nimble
import RxSwift

fileprivate struct ConversationService {
    typealias Token = String
    typealias UserID = String
    
    enum RequestError: Error {
        case malformedUrl
        case malformedBody
    }
    
    enum ServiceHosts: String {
        case rest
        case socket
        case ips
        
        var url: URL? {
            guard let endpoint = ProcessInfo.processInfo.environment["\(rawValue)_url"] else { return nil }
            return URL(string:endpoint)
        }
    }
    
    enum ServicePaths: String {
        case users
        case conversations
    }
    
    enum ServiceHeaders: String {
        case authorization
    }
    
    enum Requests {
        case createUser(name:String, displayName:String)
        case deleteUser(uuid:String)
        case deleteUserConversation(uuid:String)
    
        var path: String {
            switch self {
            case .createUser, .deleteUser:
                return ServicePaths.users.rawValue
            case .deleteUser(let uuid):
                return "\(ServicePaths.users.rawValue)/\(uuid)"
            case .deleteUserConversation(let uuid):
                return "\(ServicePaths.users.rawValue)/\(uuid)/\(ServicePaths.conversations.rawValue)"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .createUser:
                return .post
            case .deleteUser:
                return .delete
            case .deleteUserConversation:
                return .delete
            }
        }
        
        var body: Data? {
            switch self {
            case .createUser(let name, let displayName):
                return try? JSONSerialization.data(withJSONObject: ["name":name, "display_name":displayName, "channels":["type":"app", "text":"rtc"] ], options: [])
            default:
                return nil
            }
        }
        
        func asURLRequest(with token:Token) throws -> URLRequest {
            guard let baseurl = ConversationService.ServiceHosts.rest.url, let finalurl = Foundation.URL(string:self.path, relativeTo:baseurl) else {
                throw RequestError.malformedUrl
            }
   
            var request = URLRequest(url: finalurl)
            request.httpMethod = self.method.rawValue
            
            guard let payload = self.body else { throw RequestError.malformedBody}
            request.httpBody = payload
            
            request.allHTTPHeaderFields = ["Content-type": "application/json", ConversationService.ServiceHeaders.authorization.rawValue: "Bearer \(token)"]
            
            return request
        }
    }
}

/// HTTP manager for e2e
struct E2ETestManager {
    enum TestSetupError: Error {
        case userCreate
        case userDelete
    }

    static var uniqueString: String {
        return "sdk_test_" + UUID().uuidString
    }
    
    private static var adminToken: String = {
        return E2ETestManager.token(for: nil)
    }()

    // MARK:
    // MARK: Request

    static func token(for username: String?) -> String {
        var token: String = ""

        _ = try? Alamofire
            .request(url(for: "socket_url") + "/token/a5930711-1b21-4e5e-ab09-8c81389998c6" + (username != nil ? "/\(username!)" : ""))
            .responseJSON { response in
                debugPrint(response)
            
                if let json = response.result.value as? [String: Any],
                    let sessionToken = json["token"] as? String {
                    token = sessionToken
                }
            }
        
        expect(token).toEventuallyNot(equal(""))

        return token
    }
    
    static func deleteUserConversations(for user_id: String, with token: String) {
        let headers: HTTPHeaders = ["Authorization": "Bearer " + token]
        var conversations: [Any]?
        var deletedConversationsCount = 0
        
        _ = try? Alamofire
            .request(url(for: "rest_url") + "/users/" + user_id + "/conversations", headers: headers)
            .responseJSON { response in
                debugPrint(response)
            
                guard let newConversations = response.result.value as? [Any] else { return fail() }
                conversations = newConversations

                newConversations
                    .flatMap { $0 as? [String: Any] }
                    .forEach { conversation in
                        guard let cid = conversation["id"] as? String else { return }

                        _ = try? Alamofire
                            .request(url(for: "rest_url") + "/conversations/" + cid, method: .delete, headers: headers)
                            .validate()
                            .response { response in
                                guard response.error == nil else { return fail() }

                                deletedConversationsCount+=1
                            }
                    }
            }

        expect(conversations).toEventuallyNot(beNil())
        expect(deletedConversationsCount).toEventually(equal(conversations?.count), timeout: 5)
    }

    static func createUser(name:String, displayName:String?=nil) throws -> String {
        let request = try ConversationService.Requests.createUser(name: name, displayName: (displayName ?? name)).asURLRequest(with: E2ETestManager.adminToken)
        
        return try URLSession.shared.rx.json(request:request)
            .flatMap { (j:Any) -> Observable<String> in
                guard let json = j as? [String:Any], let uuid = json["id"] as? String else {
                    print("Error Parsing User Create Response json")
                    return Observable.error(TestSetupError.userCreate)
                }
                return Observable.just(uuid)
            }.toBlocking().first()!
    }
    
    static func deleteUser(id:String) throws {
        let request = try ConversationService.Requests.deleteUser(uuid: id).asURLRequest(with: E2ETestManager.adminToken)
        _ = try URLSession.shared.rx.json(request: request).toBlocking().first()
    }


    // MARK:
    // MARK: Helper

    static func url(for env: String) throws -> String {
        guard let url = ProcessInfo.processInfo.environment[env] else { fatalError("Could not get environment variable") }

        return url
    }
}
