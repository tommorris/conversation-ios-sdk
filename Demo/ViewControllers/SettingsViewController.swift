//
//  SettingsViewController.swift
//  NexmoConversation
//
//  Created by Josephine Humphreys on 29/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import UIKit
import NexmoConversation

internal class SettingsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var deviceToken: String = ""
    
    let appLifecycle = ConversationClient.instance.appLifecycle
    
    // MARK:
    // MARK: Lifecycle

    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setUp()
    }
    
    // MARK:
    // MARK: View
    
    private func setupView() {
        tableView.tableFooterView = UIView()
    }
    
    // MARK:
    // MARK: Set Up
    
    private func setUp() {
        ConversationClient.instance.appLifecycle.push.state
            .observeOnMainThread()
            .subscribe(onNext: { [weak self] pushState in
                switch pushState {
                case .registeredWithDeviceToken(let deviceToken):
                    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
                    self?.deviceToken = token
                    
                default:
                    self?.deviceToken = ""
                }
                
                self?.tableView.reloadData()
            }).disposed(by: ConversationClient.instance.disposeBag)
    }
    
    // MARK:
    // MARK: Account

    fileprivate func logout() {
        ConversationClient.instance.logout()
    }
    
    fileprivate func goToLoginScreen() {
        let storyboard = UIStoryboard.storyboard(.main)
        let viewController: LoginViewController = storyboard.instantiateViewController()
        
        navigationController?.setViewControllers([viewController], animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    // MARK:
    // MARK: UITableViewDataSource

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Logout"
        case 1:
            cell.textLabel?.text = "Push notification token"
            cell.detailTextLabel?.text = deviceToken
        case 2:
            cell.textLabel?.text = "Network logs"
        default: break
        }
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    // MARK:
    // MARK: UITableViewDelegate
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            logout()
            goToLoginScreen()
        case 1:
            UIPasteboard.general.string = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
        default: break
        }
    }
}
