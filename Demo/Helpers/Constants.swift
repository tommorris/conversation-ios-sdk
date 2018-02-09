//
//  Constants.swift
//  ConversationDemo
//
//  Created by Jodi Humphreys on 9/15/16.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// Demo constants
internal struct Constants {
    
    /// ACME
    internal struct URL {
        
        /// Auth URL
        internal static let acme: String = {
            guard let url = ProcessInfo.processInfo.environment[Constants.EnvironmentArgumentKey.acme.rawValue] else {
                return ""
            }
            
            return url
        }()
    }
    
    /// Environment argument
    internal enum EnvironmentArgumentKey: String {
        case nexmoToken = "nexmoConversationToken"
        case acme = "acme_url"
    }
    
    /// Application
    internal struct App {
        
        /// Current main application version
        internal static var version: String {
            guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return "" }

            #if DEBUG
                return "\(version) (\(build)) DEV"
            #else
                return "\(version) (\(build))"
            #endif
        }    
    }
}
