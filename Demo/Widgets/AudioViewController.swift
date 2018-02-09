//
//  AudioViewController.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 10/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import UIKit
import NexmoConversation

internal class AudioViewController: UIViewController, PresentAlert {

    private lazy var getView: AudioView = {
        guard let view = self.view as? AudioView else { fatalError() }

        return view
    }()

    internal var conversation: Conversation?

    // MARK:
    // MARK: Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enable()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        conversation?.audio.disable()
    }
    // MARK:
    // MARK: Setup

    private func setup() {
        self.navigationItem.hidesBackButton = true 
        getView.title.text = "\(self.conversation?.name ?? "App") enabling audio"

        conversation?.audio.state.asObservable().observeOnMainThread().subscribe(onNext: { [weak self] state in
            let name: String

            switch state {
            case .idle: name = "idle"
            case .connecting: name = "connecting"
            case .connected: name = "connected"
            case .disconnected: name = "disconnected"
            case .failed: name = "failed"
            }

            self?.getView.state.text = "State: \(name)"
        }).disposed(by: ConversationClient.instance.disposeBag)
    }

    // MARK:
    // MARK: Action

    private func enable() {
        do {
            try self.conversation?.audio.enable()
        } catch let error {
            self.getView.state.text = "failed: \(error)"
        }
    }

    @IBAction internal func mute(_ sender: UIButton) {
        guard let conversation = conversation else { return }

        conversation.audio.mute = !conversation.audio.mute
        sender.isSelected = conversation.audio.mute
    }

    @IBAction internal func hold(_ sender: UIButton) {
       
    }

    @IBAction internal func earmuff(_ sender: UIButton) {
        guard let conversation = conversation else { return }

        conversation.audio.earmuff = !conversation.audio.earmuff
        sender.isSelected = conversation.audio.earmuff
    }

    @IBAction internal func loudspeaker(_ sender: UIButton) {
        guard let conversation = conversation else { return }

        conversation.audio.loudspeaker = !conversation.audio.loudspeaker
        sender.isSelected = conversation.audio.loudspeaker
    }

    @IBAction internal func disable() {
        conversation?.audio.disable()

        self.navigationController?.popViewController(animated: true)
    }
}
