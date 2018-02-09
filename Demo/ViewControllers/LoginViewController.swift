//
//  AuthViewController.swift
//  NexmoChat
//
//  Created by Jonathan Tilley on 12/05/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import UIKit
import NexmoConversation

/// UserDefault keys
///
/// - username: username
internal enum UserDefaultKey: String {
    case username = "Nexmo_Conversation_Demo_Username"
}

/**
 This is the View Controller for the login screen. It's purpose is to pass the username and
 password on to the Session singleton. If you don't want to use this login screen, that is
 ok, but you must ensure Session has everything to make it happy.
 */
public class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var tokenTextField: UITextField!
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var authButton: UIButton!
    
    @IBOutlet private weak var failureMessageLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    
    @IBOutlet private weak var mode: UISegmentedControl!
    
    private let authenticationService = AuthenticationService()
    private var navigating = false
    
    // MARK:
    // MARK: Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if ConversationClient.hasToken {
            ConversationClient.instance.account.state.asObservable().subscribe(onNext: { [weak self] _ in
                if ConversationClient.instance.account.state.value != .loggedOut {
                    print("DEMO - Account state \(ConversationClient.instance.account.state.value)")
                    self?.navigateOnLogin()
                }
            }).disposed(by: ConversationClient.instance.disposeBag)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigating = false
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK:
    // MARK: Setup
    
    private func setupUI() {
        failureMessageLabel.isHidden = true
        
        usernameTextField.text = UserDefaults.standard.string(forKey: UserDefaultKey.username.rawValue)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "v" + version
        }
        
        tokenTextField.text = ProcessInfo.processInfo.environment[Constants.EnvironmentArgumentKey.nexmoToken.rawValue]
    }
    
    // MARK:
    // MARK: Action
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        guard let username = usernameTextField.text?.replacingOccurrences(of: " ", with: ""), !username.isEmpty else { return }
        
        print("DEMO - Logging in with user: \(username)")
        
        failureMessageLabel.isHidden = true

        save(username)
        validateUsername(username) { [weak self] model in self?.login(model.token) }
    }
    
    @IBAction func authButtonPressed(_ sender: AnyObject) {
        // Check the token in environment variable, can be found in target scheme setting under build
        
        if let tokenText = tokenTextField.text, !tokenText.isEmpty {
            print("Demo - launching with entered token value")
            login(tokenText)
            
            return
        }
        
        guard let token = ProcessInfo.processInfo.environment[Constants.EnvironmentArgumentKey.nexmoToken.rawValue],
            !token.isEmpty else {
            print("Demo - auth token not in environment variable, set in target scheme setting under build")
            
            return
        }
        
        print("Demo - launching with tokens in environment variable")
            
        login(token)
    }
    
    // MARK:
    // MARK: UITextFieldDelegate
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        failureMessageLabel.isHidden = true
    
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            textField.resignFirstResponder()
        } else if textField == tokenTextField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK:
    // MARK: Login
    
    /// Login with token
    private func login(_ token: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("DEMO - AppDelegate\(String(describing: UIApplication.shared.delegate)) is the wrong class type")

            return
        }
        
        if mode.selectedSegmentIndex == 0 { // dev
            ConversationClient.developmentMode(true)
            UserDefaults.standard.set(true, forKey: "DevelopmentEnvironment")
        } else { // prod
            ConversationClient.developmentMode(false)
            UserDefaults.standard.set(false, forKey: "DevelopmentEnvironment")
        }
        
        _ = UserDefaults.standard.synchronize()
        
        if let env = UserDefaults.standard.value(forKey: "DevelopmentEnvironment") as? Bool {
            ConversationClient.developmentMode(env)
        }
        
        appDelegate.client.login(with: token)
            .subscribe(onSuccess: { [weak self] in
                self?.navigateOnLogin()
                print("DEMO - login successful")
            }, onError: { [weak self] error in
                self?.failureMessageLabel.isHidden = false

                let reason: String = {
                    switch error {
                    case LoginResult.failed: return "failed"
                    case LoginResult.invalidToken: return "invalid token"
                    case LoginResult.sessionInvalid: return "session invalid"
                    case LoginResult.expiredToken: return "expired token"
                    case LoginResult.success: return "success"
                    default: return "unknown"
                    }
                }()

                print("DEMO - login unsuccessful with \(reason)")
            })
            .disposed(by: appDelegate.client.disposeBag)
    }
    
    func navigateOnLogin() {
        guard !navigating else { return }
        navigating = true
        
        let storyboard = UIStoryboard.storyboard(.main)
        let viewController: ConversationListViewController = storyboard.instantiateViewController()
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    /// Authenticate user with username and password
    private func validateUsername(_ username: String, _ completion: @escaping (AuthenticationModel) -> Void) {
        authenticationService.validate(email: username) { [weak self] result in
            switch result {
            case .success(let model):
                completion(model)
            case .failure(_):
                print("DEMO - auth unsuccessful")
                
                self?.failureMessageLabel.isHidden = false
            }
        }
    }
    
    // MARK:
    // MARK: UserDefault

    /**
     Store the username and password persistently.
     
     - parameter username: Username, nil to clear.
     - parameter password: Password, nil to clear.
     */
    private func save(_ username: String) {
        let preferences = UserDefaults.standard
        
        preferences.set(username, forKey: UserDefaultKey.username.rawValue)
        preferences.synchronize()
    }
}
