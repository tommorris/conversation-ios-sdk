//
//  PushNotificationService.swift
//  NexmoConversation
//
//  Created by shams ahmed on 16/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Alamofire

/// Push notification service request
internal struct PushNotificationService {

    /// Uniqle application id
    private var applicationId: String { return AccountController.applicationId }
    
    /// Network manager
    private let manager: HTTPSessionManager
    
    // MARK:
    // MARK: Initializers
    
    internal init(manager: HTTPSessionManager) {
        self.manager = manager
    }
    
    // MARK:
    // MARK: GET
    
    /// retrieve APNS certificate
    ///
    /// - parameter success: push notification token
    /// - parameter failure: failed result with error
    ///
    /// - returns: request
    @discardableResult
    internal func retrieveCertificate(success: @escaping ([PushNotificationCertificate]) -> Void, failure: @escaping (Error) -> Void) -> DataRequest {
        return manager
            .request(PushNotificationRouter.retrieveCertificate(applicationToken: applicationId))
            .validateAndReportError(to: manager)
            .responseData(queue: manager.queue) { response in
                switch response.result {
                case .success(let response):
                    let models = (try? JSONDecoder().decode([PushNotificationCertificate].self, from: response)) ?? [PushNotificationCertificate]()
                    
                    success(models)
                case .failure(let error):
                    failure((try? NetworkError(from: response)) ?? error)
                }
        }
    }
    
    // MARK:
    // MARK: PUT
    
    /// Add/Update device token a user
    ///
    /// - parameter deviceToken: device token for UIApplicationDelegate
    /// - parameter deviceId:    device id
    /// - parameter success:     success result
    /// - parameter failure:     failure result
    ///
    /// - returns: request
    @discardableResult
    internal func update(deviceToken: Data, deviceId: String, success: (() -> Void)? = nil, failure: ((Error) -> Void)? = nil) -> DataRequest {
        return manager
            .request(PushNotificationRouter.updateDevice(id: deviceId, deviceToken: deviceToken))
            .validateAndReportError(to: manager)
            .response(completionHandler: {
                guard $0.error == nil else {
                    let error: NetworkError? = NetworkError(from: $0)
                    
                    failure?(error ?? HTTPSessionManager.Errors.requestFailed(error: $0.error))

                    return
                }
                
                success?()
            }
        )
    }
    
    /// Upload certificate
    ///
    /// - parameter certificate: certificate blon
    /// - parameter password: password for APNS certificate
    /// - parameter success: success result
    /// - parameter failure: failed result with error
    ///
    /// - returns: request
    @discardableResult
    internal func upload(certificate: Data, password: String? = nil, success: ((String) -> Void)? = nil, failure: ((Error) -> Void)? = nil) -> DataRequest {
        return manager
            .request(PushNotificationRouter.upload(certificate: certificate, password: password, applicationToken: applicationId))
            .validateAndReportError(to: manager)
            .responseJSON(queue: manager.queue, completionHandler: {
                switch $0.result {
                case .failure(let error):
                    failure?((try? NetworkError(from: $0)) ?? error)
                case .success(let response):
                    // TODO: create a model of response
                    guard let token = (response as? Parameters)?["token"] as? String else {
                        failure?(JSONError.malformedJSON)

                        return
                    }

                    success?(token)
                }
            }
        )
    }
    
    // MARK:
    // MARK: DELETE
    
    /// Remove all APNS certificate
    ///
    /// - parameter success: success result
    /// - parameter failure: failed result with error
    ///
    /// - returns: request
    @discardableResult
    internal func removeAllCertificate(success: (() -> Void)? = nil, failure: ((Error) -> Void)? = nil) -> DataRequest {
        return manager
            .request(PushNotificationRouter.removeAllCertificate(applicationToken: applicationId))
            .validateAndReportError(to: manager)
            .response(completionHandler: {
                guard $0.error == nil else {
                    let error: NetworkError? = NetworkError(from: $0)
                    
                    failure?(error ?? HTTPSessionManager.Errors.requestFailed(error: $0.error))

                    return
                }
                
                success?()
            }
        )
    }
    
    /// Remove device token
    ///
    /// - parameter id: device id
    /// - parameter success: success result
    /// - parameter failure: failed result with error
    ///
    /// - returns: request
    @discardableResult
    internal func removeDeviceToken(deviceId: String, success: (() -> Void)? = nil, failure: ((Error) -> Void)? = nil) -> DataRequest {
        return manager
            .request(PushNotificationRouter.deleteDeviceToken(id: deviceId))
            .validateAndReportError(to: manager)
            .response(completionHandler: {
                guard $0.error == nil else {
                    let error: NetworkError? = NetworkError(from: $0)
                    
                    failure?(error ?? HTTPSessionManager.Errors.requestFailed(error: $0.error))

                    return
                }
                
                success?()
            }
        )
    }
}
