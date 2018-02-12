0.19.2 / 8-2-2018
==================

Fix issue where muting did not work on second attempt and issues where full sync had to happen on second launch due to database permissions.


0.19.1 / 2-2-2018
==================

Fix cocoapods build


0.19.0 / 1-2-2018
==================

# Breaking changes
`AudioEvent` has now be renamed to `MediaEvent` to reflect other media type that will soon be available 
```swift
let event = event as? MediaEvent
```


`invitations` in `RTCController` has been renamed to `media` getter

Old:
```swift
client.rtc.invitations
```

New:
```swift
client.media.invitations
```


`MessageSent` in `Conversation` class has now moved to `EventCollection` inside the `Conversation` class
Old:
```swift
conversation.messageSent.addHandler { event in
    // sent event here...            
}
```

New:
```swift
conversation.events.eventSent.addHandler { event in
    // sent event here...            
}
```

# Changes
Documentation has been updated to reflect most recent API change. This should now be much more simple to understand

Removed GLOSS dependency for Swift 4 JSON


0.18.1 / 26-12-2017
==================
# Bugs
* Fixed RTC build issue


0.18.0 / 26-12-2017
==================
# Feature
* Support Swift 4 and Xcode 9+


0.18.2 / 1-1-2018
==================
# Bugs
* Fixed build issue


0.18.1 / 26-12-2017
==================
# Bugs
* Fixed RTC build issue


0.18.0 / 26-12-2017
==================
# Feature
* Support Swift 4 and Xcode 9+


0.17.0 / 20-12-2017
==================
# Bugs
* Handle empty JSON object returned from DELETE event request
* iOS pass APNS device token and environment (debug / release) to back end on login

# Feature
* Expose push notification status
* Enable / disable audio in a conversation that I am a member of
* Event when another user has enabled / disabled audio in conversation
* Enable / disable loudspeaker


0.16.0 / 06-11-2017
==================
# Bugs
* Draft events were not getting deleted
* Removed trailing slash at end of URL on image download

0.15.0 / 14-09-2017
==================
# Breaking Change
  * Database changes, please reinstall the app
# Feature
  * Fetch images from media server
  * IOS 10 UserNotifications framework supported
  * Download image method 
  * Image caching

0.14.0 / 14-09-2017
==================
# Breaking Change
  * `client.conversation.new(Model, withJoin)` now requires a `String` with a display name
# Feature
  * Auto-reconnect mechanism via feature toggle
# Changes
  * Refactor error messages to be readable


0.13.0 / 05-09-2017
==================

# Bugs
  * Conversation.left() method & received member:left event do not update member state
  * Sending typing does not update current member typing status
  * Dont persist created conversation that we have not joined


0.12.0 / 21-08-2017
==================

# Feature
  * Fetch user 
  * Auto reconnect
# Bugs
  * Fix crash on sync


0.11.0 / 08-08-2017
==================

# Feature
  * Conversation collection updated for incoming contextual event i.e text and image
  * Expose a reason for new conversation insert i.e "invited by"
  * Exposed timestamp of member states
# Bugs
  * Fix crash on sync
  * Made sure date foramtter created ones 
  * Reduce excess consuming of memory by about 80%
  * Handle member already has joined error


0.10.0 / 21-07-2017
==================

# Feature
  * Conversation collection can now be observed 
# Bugs
  * Fix crash on sync
  * Event body savedwith the correct format 


0.9.3 / 06-07-2017
==================

# Breaking change
  * accountController renamed to account
  * conversationController renamed to conversation
  * client.close() renamed to client.disconnect() 
# Feature
 * Kick member from own object
# Bugs
  * Fixed issue where sync could not be completed


0.9.2 / 30-06-2017
==================

# Bugs
  * Remove join checks when making network request


0.9.1 / 26-06-2017
==================

# Feature  
  * Equatable for public enum
  * Update event that are deleted and insert new type, timestamp and payload
# Bugs
  * Connects twice on first run
  

0.9.0 / 16-06-2017
==================

# Breaking change
  * Create conversation returns a facade object rather then the REST model
  * Removed Objective-C prefix NXM and NX for Swift
# Feature
  * Custom log level. use `Configuration.default`
  * Internal error reporting. use `Client.internalNetworkError`
# Bugs
  * Fix issue where display name was not set
  * Fix issue with creating new conversation with same name failed


0.8.0 / 31-05-2017
==================

# Breaking changes
  * Deprecated
    `client.connectionStatusChanged`
    `client.syncComplete`
  * New
    `client.state`
    ```
      /// Global state of client
      ///
      /// - disconnected: Default state SDK has disconnected from all services. triggered on user logout/disconnects and inital state
      /// - connecting: Requesting permission to reconnect
      /// - connected: Connected to all services
      /// - outOfSync: SDK is not in sync yet
      /// - synchronizing: Synchronising with current progress state
      /// - synchronized: synchronised all services and ready to be used
      enum State {
      case disconnected
      case connecting
      case connected
      case outOfSync
      case synchronizing(SynchronizingState)
      case synchronized
      }

      /// State of synchronizing
      ///
      /// - conversations: processing conversations
      /// - events: processing events
      /// - members: processing members
      /// - users: processing users
      /// - receipt: processing receipts
      /// - tasks: sending all unsent request i.e events
      enum SynchronizingState {
      case conversations
      case events
      case members
      case users
      case receipt
      case tasks
      }
    ```
# Changes
  * Client console log configurable uisng `Configuration` class. i.e 
  ```
   client.configuration = Configuration(with: .info)
   client.login(with: TOKEN)
  ```


0.7.0 / 26-04-2017
==================

# Changes
  * Remove seenDate and deliveredDate from receipt records. Only keep NXMReceiptRecord.date as we know the type already
  * Change User.me to: accountController.user 
  * Send event is now done in one step i.e send(String), send(Image)
  * Same conversation object is not passed back in callbacks
  * 'setTrying(:Bool)' is now two methods called start and stop
  * Exposed last event id in conversation
  * Renamed some classses to only use prefix in Objective-c
  * Updated dependencies
  * Updated docs
# Bugs 
  * Bug fixes

0.6.1 / 11-04-2017
==================

# Feature
  * better access of user state
  * Delete events
# Bugs
  * Bug fixes
# Changes
  * Stabilised SDK
  * Updated dependencies
  * Updated docs
  * Support for Carthage
  * New framework on Git tag

0.0.6 / 24-03-2017
==================

# Bugs 
  * Bug fixes
# Changes
  * Expose conversation and Event method
  * Stabilised SDK
  * Updated dependencies

0.0.5 / 08-11-2016
==================

# Bugs 
  * Bug fixes
  * Base URL not points to prod

0.0.4 / 04-10-2016
==================

# Feature
  * Send image
  * IPS
  * Push notification support

0.0.3 / 07-10-2016
==================

# Bugs 
  * Bug fixes
# Changes
  * Minor framework update

0.0.1 / 04-10-2016
==================

# Changes
  * Initial commit
