//
//  ConversationManageViewController.swift
//  NexmoConversation
//
//  Created by James Green on 28/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import NexmoConversation

public class ConversationManageViewController: UIViewController, UserSelectionDelegate, PresentAlert {
    @IBOutlet private weak var conversationName: UITextField!
    @IBOutlet private weak var conversationAvatar: AvatarWidget!
    @IBOutlet private weak var charactersRemaining: UILabel!
    @IBOutlet private weak var userSelectionWidget: UserSelectionWidget!
    @IBOutlet private weak var membersTable: ConversationManageMembersListWidget!
    
    private var conversation: Conversation?

    // MARK:
    // MARK: Initialize

    public func initialise(conversation: Conversation) {
        self.conversation = conversation
    }

    // MARK:
    // MARK: Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        conversationName.text = conversation?.name

        /* Initialise widgets. */
        membersTable.initialise(conversation: self.conversation)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let conversation = conversation, conversation.audio.state.value != .idle {
            conversation.audio.disable()
        }
    }

    // MARK:
    // MARK: Setup

    private func setup() {
        /* Remove back button text */
        navigationController?.navigationBar.topItem?.title = ""

        /* Initialise widgets. */
        userSelectionWidget.delegate = self
        
        bindUI()
    }

    private func bindUI() {
        membersTable.didSelect = { _ in
            let audio: AudioViewController = UIStoryboard.storyboard(.audio).instantiateViewController()
            audio.conversation = self.conversation

            // enable audio at the start
            self.navigationController?.pushViewController(audio, animated: true)
            //self.present(audio, animated: true)
        }
    }

    // MARK:
    // MARK: UI

    public func onUserSelected(userId: String?, username: String) {
        let alert = UIAlertController(title: "Invite user with type", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Invite", style: .default, handler: { _ in
            self.invite(userId: userId, username: username, withAudio: false)
        }))
        alert.addAction(UIAlertAction(title: "Invite with Audio", style: .default, handler: { _ in
            self.invite(userId: userId, username: username, withAudio: true)

            let audio: AudioViewController = UIStoryboard.storyboard(.audio).instantiateViewController()
            audio.conversation = self.conversation
            
            self.navigationController?.pushViewController(audio, animated: true)
        }))

        present(alert, animated: true, completion: nil)
    }

    // MARK:
    // MARK: Invite

    private func invite(userId: String?, username: String, withAudio audio: Bool) {
        conversation?.invite(username, userId: userId, with: audio ? .audio(muted: false, earmuffed: false) : nil)
            .subscribe(onError: { [weak self] _ in
                let errorAlert = UIAlertController(title: "Error", message: "Failed to invite user", preferredStyle: UIAlertControllerStyle.alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))

                self?.present(errorAlert, animated: true)
        }).disposed(by: ConversationClient.instance.disposeBag)
    }
}
