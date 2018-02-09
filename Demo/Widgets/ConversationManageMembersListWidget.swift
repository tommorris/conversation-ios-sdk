//
//  ConversationManageMembersListWidget.swift
//  NexmoConversation
//
//  Created by James Green on 28/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import NexmoConversation

public class ConversationManageMembersListWidget: UITableView, UITableViewDelegate, UITableViewDataSource {

    internal var conversation: Conversation?
    private var members: NexmoConversation.LazyCollection<Member>?

    internal var didSelect: ((IndexPath) -> Void)?
    private var membersChanged: SignalReference?
    private var memberLeft: SignalReference?
    private var memberInvited: SignalReference?
    
    // MARK:
    // MARK: Initialise

    deinit {
        if let membersChanged = membersChanged {
            self.conversation?.membersChanged.removeHandler(membersChanged)
        }
        if let memberLeft = memberLeft {
            self.conversation?.memberLeft.removeHandler(memberLeft)
        }
        if let memberInvited = memberInvited {
            self.conversation?.membersChanged.removeHandler(memberInvited)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        dataSource = self
    }

    public func initialise(conversation: Conversation?) {
        self.conversation = conversation
        self.members = conversation?.members
        setup()
    }

    // MARK:
    // MARK: Setup
    
    private func setup() {
        membersChanged = self.conversation?.membersChanged.addHandler { [weak self] _ in
            self?.members = self?.conversation?.members
            self?.reloadData()
        }
        
        memberLeft = self.conversation?.memberLeft.addHandler { [weak self] _ in
            self?.reloadData()
        }
        
        memberInvited = self.conversation?.memberInvited.addHandler { [weak self] _ in
            self?.reloadData()
        }
    }
    
    // MARK:
    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.members != nil {
            return self.members!.count
        } else {
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemberListCellWidget? = tableView.dequeueReusableCell(withIdentifier: "MemberListCellWidget") as! MemberListCellWidget?
        
        let member = members![indexPath.row]
        cell?.setMember(member: member)
        
        return cell!
    }

    // MARK:
    // MARK: UITableViewDelegate

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var result = [UITableViewRowAction]()

        /* Leave. */
        let leave = UITableViewRowAction(style: .normal, title: "Remove", handler: { (_, indexPath) -> Void in
            let member = self.members![indexPath.row]
            
            _ = member.kick().subscribe(onSuccess: { [weak self] in
                self?.reloadData()
            })
        })
        
        leave.backgroundColor = UIColor.red
        result.append(leave)
        
        return result
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let member = members?[indexPath.row] else { return false }
        
        return member.state != .left
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect?(indexPath)
    }
}
