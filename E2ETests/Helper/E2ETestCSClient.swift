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

enum RequestError: Error {
    case malformedUrl
    case malformedBody
    case malformedAppID
}

fileprivate struct ConversationService {
    typealias Token = String
    typealias UserID = String
    
    enum ServiceHosts: String {
        case rest
        case socket
        case ips
        case token
        
        var url: URL? {
            guard let endpoint = ProcessInfo.processInfo.environment["\(rawValue)_url"] else { return nil }
            // Need to append backslash otherwise joining urls removes partial paths
            return URL(string:(endpoint.characters.last == "/" ? endpoint : endpoint + "/"))
        }
    }
    
    enum ServicePaths: String {
        case users
        case conversations
        case token
    }
    
    enum ServiceHeaders: String {
        case authorization
    }
    
    enum Requests {
        case createUser(name:String, displayName:String)
        case deleteUser(uuid:String)
        case deleteUserConversation(uuid:String)
        case getUserConversations(user:String)
        case getToken(user:String?, app:String)
    
        var path: String {
            switch self {
            case .createUser, .deleteUser:
                return ServicePaths.users.rawValue
            case .deleteUser(let uuid):
                return "\(ServicePaths.users.rawValue)/\(uuid)"
            case .deleteUserConversation(let uuid):
                return "\(ServicePaths.users.rawValue)/\(uuid)/\(ServicePaths.conversations.rawValue)"
            case .getUserConversations:
                return "\(ServicePaths.users.rawValue)/\(ServicePaths.conversations.rawValue)"
            case .getToken(let user, let app):
                return "\(ServicePaths.token.rawValue)/\(app)" + ( user != nil ? "/\(user!)" : "")
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
            case .getUserConversations:
                return .get
            case .getToken:
                return .get
            }
        }
        
        var body: Data? {
            switch self {
            case .createUser(let name, let displayName):
                return try? JSONSerialization.data(withJSONObject: ["name":name, "display_name":displayName, "channels":["type":"app", "text":"rtc"] ], options: [])
            default:
                return Data()
            }
        }
        
        func asURLRequest(with token:Token?, host:URL?=nil) throws -> URLRequest {
            guard let baseurl = host ?? ConversationService.ServiceHosts.rest.url, let finalurl = Foundation.URL(string:self.path, relativeTo:baseurl) else {
                throw RequestError.malformedUrl
            }
   
            var request = URLRequest(url: finalurl)
            request.httpMethod = self.method.rawValue
            
            guard let payload = self.body else { throw RequestError.malformedBody}
            request.httpBody = payload
            
            var headers = ["Content-type": "application/json"]
            if let token = token {
                headers[ConversationService.ServiceHeaders.authorization.rawValue] = "Bearer \(token)"
            }
            request.allHTTPHeaderFields = headers
            
            return request
        }
    }
}

/// HTTP manager for e2e
struct E2ETestCSClient {
    enum TestSetupError: Error {
        case userCreate
        case userDelete
    }

    static var uniqueString: String {
        return "sdk_test_" + UUID().uuidString
    }
    
    private static var adminToken: String = {
        do {
            return try E2ETestCSClient.token(for: nil)
        }
        catch {
            print(error)
            fatalError("Unable to create Admin Token")
        }
    }()

    // MARK:
    // MARK: Request
    
    static func token(for username: String?, application:String? = nil) throws -> String {
        guard let app = application ?? ProcessInfo.processInfo.environment["app_id"] else {
            throw RequestError.malformedAppID
        }
        
        let host = ConversationService.ServiceHosts.token.url, request = try ConversationService.Requests.getToken(user: username, app:app).asURLRequest(with: nil, host:host)
        
        return try URLSession.shared.rx.json(request:request)
            .flatMap { (j:Any) -> Observable<String> in
                guard let json = j as? [String:Any], let token = json["token"] as? String else {
                    print("Error Parsing token Create Response json")
                    return Observable.error(TestSetupError.userCreate)
                }
                return Observable.just(token)
        }
        .retry(2)
        .toBlocking().first()!
    }
    
    static func deleteUserConversations(for userId: String, with token:String?) throws  {
        let conversationsRequest = try ConversationService.Requests.getUserConversations(user: userId).asURLRequest(with: token ?? E2ETestCSClient.adminToken)
        
        _ = try URLSession.shared.rx.json(request:conversationsRequest)
            .flatMap { (j:Any) -> Observable<String> in
                guard let json = j as? [[String:Any]] else {
                    return Observable.error(TestSetupError.userCreate) // FIXME
                }
                let conversations = json.flatMap { $0["id"] as? String }
                
                return Observable.from(conversations) // this should return an observable over each elemet
            }
            .retry(2)
            .flatMap { (uuid:String) -> Observable<Any> in
                let request = try ConversationService.Requests.deleteUserConversation(uuid: uuid).asURLRequest(with: E2ETestCSClient.adminToken)
                return URLSession.shared.rx.json(request:request)
        }.toBlocking()
    }
    
    static func createUser(name:String, displayName:String?=nil) throws -> String {
        let request = try ConversationService.Requests.createUser(name: name, displayName: (displayName ?? name)).asURLRequest(with: E2ETestCSClient.adminToken)
        
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
        let request = try ConversationService.Requests.deleteUser(uuid: id).asURLRequest(with: E2ETestCSClient.adminToken)
        _ = try URLSession.shared.rx.json(request: request).toBlocking().first()
    }


    // MARK:
    // MARK: Helper

    static func url(for env: String) throws -> String {
        guard let url = ProcessInfo.processInfo.environment[env] else { fatalError("Could not get environment variable") }

        return url
    }
}
