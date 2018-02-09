# Sources
source 'git@github.com:Nexmo/PodSpec.git'
source 'git@github.com:CocoaPods/Specs.git'

# Configurations
platform :ios, '9.0'
use_frameworks!

# Dependencies
def shared_pods
    # Database
    pod 'GRDB.swift', :git => 'git@github.com:Nexmo/GRDB.swift.git', :branch => 'xcode_fix' # https://github.com/groue/GRDB.swift
    
    # Networking
    pod 'Alamofire' # https://github.com/Alamofire/Alamofire
    pod 'Socket.IO-Client-Swift' # https://github.com/socketio/socket.io-client-swift
    pod 'NexmoWebRTC'

    # Rx
    pod 'RxCocoa' # https://github.com/ReactiveX/RxSwift
end

def shared_test_pods
    pod 'RxBlocking', :configuration => 'Debug', :inhibit_warnings => true
    pod 'RxTest', :configuration => 'Debug', :inhibit_warnings => true
    pod 'Nimble', :configuration => 'Debug', :inhibit_warnings => true
    pod 'Quick', :configuration => 'Debug', :inhibit_warnings => true
    pod 'Mockingjay', :configuration => 'Debug', :git => 'git@github.com:kylef/Mockingjay.git', :branch => 'master', :inhibit_warnings => true
end

# Targets
target 'NexmoConversation' do
    inherit! :search_paths
    
    shared_pods

    target 'Tests' do
        inherit! :search_paths

        shared_test_pods
    end
    target 'E2ETests' do
        inherit! :search_paths

        shared_test_pods
    end
    target 'HermeticTests' do
        inherit! :search_paths

        shared_test_pods
    end
end 

target 'ConversationDemo' do 
    inherit! :search_paths

    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'HermeticTests' || target.name == 'E2ETests' || target.name == 'Tests'
            target.build_configurations.each do |config|
                config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
            end
        end
    end
end
