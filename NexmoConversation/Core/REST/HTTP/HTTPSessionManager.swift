//
//  HTTPSessionManager.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 01/11/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

/// HTTP Session manager
internal class HTTPSessionManager: SessionManager {
    
    // MARK:
    // MARK: Enum
    
    /// Error state
    ///
    /// - requestFailed: bad request with error
    /// - cancelled: cancelled due to network or task
    /// - invalidToken: invalid token
    internal enum Errors: Error {
        case requestFailed(error: Any?)
        case cancelled
        case invalidToken
    }
    
    /// Common keys for http header
    ///
    /// - authorization: authorization token
    /// - session: session id to help CAPI
    internal enum HeaderKeys: String {
        case authorization = "Authorization"
        case session = "X-Nexmo-SessionId"
    }
    
    internal let queue: DispatchQueue
    internal let errorListener: Variable<NetworkErrorProtocol?> = Variable<NetworkErrorProtocol?>(nil)
    internal let reachabilityManager = ReachabilityManager()
    
    // MARK:
    // MARK: Initializers
    
    internal init(queue: DispatchQueue) {
        self.queue = queue
        
        // TODO: Add SSL pinning support
        super.init(
            configuration: SessionConfiguration.default,
            delegate: SessionDelegate(),
            serverTrustPolicyManager: nil
        )
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        retrier = RequestRetry()
        adapter = AuthorizationAdapter()
    }
}
