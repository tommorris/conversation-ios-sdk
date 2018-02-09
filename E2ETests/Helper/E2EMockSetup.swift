//
//  SuiteConfiguration.swift
//  NexmoConversation
//
//  Created by Ashley Arthur on 19/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import NexmoConversation

typealias UserInfo = (name:String, displayName:String, uuid:String)

struct Mock {
    static let userNamePrefix = "ios-sdk-e2e"
    static let placeholderUser = (name: "placeholder", displayName:"User", uuid:"1")
    
    static fileprivate(set) var user: UserInfo = Mock.placeholderUser
    static fileprivate(set) var peerUser: UserInfo = Mock.placeholderUser
}

extension Mock {
    typealias MockUserData = (users:[UserInfo],remove:()->())
    
    static func setup() throws -> MockUserData {
        let baseUserNames = ["User1","Peer1"]
        
        let createdUsers = baseUserNames.map {
            (name:"\(Mock.userNamePrefix)-\($0)-\(UUID().uuidString)", displayName:$0)
            }.flatMap { (name:String, displayName:String) -> UserInfo? in
                do {
                    let uuid = try E2ETestCSClient.createUser(name:name,displayName:displayName)
                    return (name,displayName,uuid)
                }
                catch {
                    print("Error Creating User")
                    print(error.localizedDescription)
                    return nil
                }
        }
        
        for user in createdUsers {
            // Update Mock
            switch user.displayName {
            case "User1": Mock.user = user
            case "Peer1": Mock.peerUser = user
            default:
                break
            }
        }
        
        return (createdUsers,{ () -> () in
            for user in createdUsers {
                do {
                    try E2ETestCSClient.deleteUser(id: user.uuid)
                }
                catch {
                    print("Error Deleting User")
                    print(error.localizedDescription)
                }
                // Remove access to old user incase it affects subsequent suites
                switch user.displayName {
                case "User1": Mock.user = Mock.placeholderUser
                case "Peer1": Mock.peerUser = Mock.placeholderUser
                default:
                    break
                }
            }
        })
    }
}





