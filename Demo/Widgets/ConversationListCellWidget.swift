//
//  ConversationListCellWidget.swift
//  NexmoChat
//
//  Created by James Green on 26/05/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import UIKit
import NexmoConversation

public class ConversationListCellWidget: UITableViewCell {
    @IBOutlet weak var avatarWidget: AvatarWidget!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var handlerRefNewEventReceived: SignalReference?
    
    var conversation: Conversation? {
        didSet {
            /* Out with the old. */
            handlerRefNewEventReceived?.dispose()

            /* In with the new. */
            handlerRefNewEventReceived = conversation?.events.newEventReceived.addHandler(self, handler: ConversationListCellWidget.handleNewEventReceived)
            
            refresh()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        refresh()
    }
    
    private func refresh() {
        if conversation != nil {
            nameLabel.text = conversation?.name
            avatarWidget.conversation = conversation
            refreshLastMessage()
        } else {
            nameLabel.text = ""
        }        
        
        if let state = self.conversation?.state {
            switch state {
            case .left:
                self.messageLabel.text = "Left Conversation"
                self.messageLabel.textColor = UIColor.red
            case .invited:
                self.messageLabel.text = "New Invitation. Tap to join"
                self.messageLabel.textColor = UIColor.blue
            case .joined:
                self.messageLabel.textColor = UIColor.darkGray
            case .unknown:
                conversation?.markIncomplete()
                conversation?.markRequiresSync()
                self.messageLabel.textColor = UIColor.darkGray
            }
        }
    }
    
    private func refreshLastMessage() {
        let mostRecentEvent = conversation?.events.last
        
        if let event = mostRecentEvent as? TextEvent {
            dateLabel.text = DateHelper.prettyPrint(event.createDate)
            
            if event.text != nil {
                messageLabel.text = event.text
            } else {
                messageLabel.text = ""
            }
        } else if mostRecentEvent is ImageEvent {
            messageLabel.text = "Image"
        } else if let event = mostRecentEvent as? MediaEvent {
            let state = event.enabled ? "enabled" : "disabled"
                
            messageLabel.text = "\(event.fromMember.user.displayName) \(state) audio"
        } else {
            dateLabel.text = ""
            messageLabel.text = ""
        }
    }

    private func handleNewEventReceived(event: EventBase) {
        DispatchQueue.main.async {
            self.refreshLastMessage()
        }
    }
}
