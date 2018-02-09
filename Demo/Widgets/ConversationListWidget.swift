//
//  ConversationListWidget.swift
//  NexmoChat
//
//  Created by James Green on 26/05/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import UIKit
import NexmoConversation

/**
 This widget shows a list of all conversation in a table. The superview/parent must
 call initialise() and close() to maintain the widget's lifecycle.
 */
public class ConversationListWidget: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // Has same ordering as indexPath
    private var conversations: ConversationCollection?
    internal var delegateConversationList: ConversationListDelegate?
    internal var numberOfConversations: Int {
        return conversations?.count ?? 0
    }
    
    // MARK:
    // MARK: Initializers

    public override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup() {
        delegate = self
        dataSource = self

        conversations = ConversationClient.instance.conversation.conversations
    }

    /**
     Refetch the list of conversations. Take it from the top again.
     */
    public func refresh() {
        // TODO - Make this a new animated insert rather than just a table refresh.
        conversations = ConversationClient.instance.conversation.conversations // Get the latest list.
        
        reloadData()
        
        if numberOfConversations > 0 {
            scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    // MARK:
    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfConversations
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Prepare a cell to show this conversation. */
        let cell: ConversationListCellWidget? = tableView.dequeueReusableCell(withIdentifier: "ConversationListCellWidget") as! ConversationListCellWidget?
        
        let conversation = conversations![indexPath.row]
        cell?.conversation = conversation

        return cell!
    }

    // MARK:
    // MARK: UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Tell our parent/delegate that a conversation has been selected. */
        if (delegateConversationList != nil) {
            let conversation = conversations![indexPath.row]
            delegateConversationList?.onConversationSelected(conversation: conversation)
        }
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        /* A row has been swiped, so show the appropriate options. */
        guard let conversation = self.conversations?[safe: indexPath.row] else { return nil }
        
        var result = [UITableViewRowAction]()
        
        /* Leave option. */
        let leave = UITableViewRowAction(style: .normal, title: "Leave", handler: { (_, indexPath: IndexPath!) -> Void in
            /* Issue leave. */
            _ = conversation.leave().subscribe(onSuccess: { [weak self] in
                self?.refresh()
            })
        })
        
        leave.backgroundColor = UIColor.red
        result.append(leave)
        
        return result
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        /* Dont allow editing (i.e. show leave button) if already left the conversation */
        guard let conversation = self.conversations?[safe: indexPath.row] else { return false }
        
        return !(conversation.state == .left)
    }
}
