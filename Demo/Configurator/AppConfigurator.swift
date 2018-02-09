//
//  AppConfigurator.swift
//  ConversationDemo
//
//  Created by shams ahmed on 19/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import NexmoConversation
import AVFoundation

/// App Configurator
internal class AppConfigurator: NSObject {
    
    /// App launch options
    private let launchOptions: [UIApplicationLaunchOptionsKey : Any]?

    // MARK:
    // MARK: Initializers
    
    internal init(launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions

        super.init()
        
        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)

            session.requestRecordPermission { _ in }
        } catch  {
            print(error)
        }
    }
}
