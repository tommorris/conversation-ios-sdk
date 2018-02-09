# Design Rationale

The purpose of this document is to give a high-level overview of various design patterns and decisions undertaken for the iOS SDK.

### Architecture  
The SDK is written following a multitier architecture (layered architecture) where the components within the layered architecture pattern are organised into horizontal layers, each layer performing a specific role and with its own responsibility. By using such an approach we're able to form an abstraction around the work that needs to be done to satisfy a particular business request.

One key benefit is the ability to have separation of concerns and conform to single responsibility principle among components. The Xcode project is set up to demonstrate this architecture as you can see from the folder structure. Its common to see layers such as routers, service, controller, managers and so on...

The concept follows the same direction as Apple's UIKit framework which uses the same architecture for the underlying hardware and the apps you create.

#### Common design patterns

Communication:  
- Incoming: async communication via WebSocket  
- Outgoing: rest request (HTTP 1.2)

Storage:  
- Persistent storage (SQLite)  
- DAO  
- In-Memory lazy caching on both Mobile SDK  

Public interface:  
- Facade objects

Observation Patterns:
- Swift (public/internal): Reactive programming (Rx)  
- Obj-c (public): Closure callback (onSucces: onFailure:)  

### Language
All development of the SDK is in Swift language with a big focus on utilising Swifts many powerful features i.e enum, struct i.e enum, struct, generics, protocols etc. To support Objective-c backward compatibility we expose our Facade object as `@objc` and `NSObject`. Where the property/methods are only for Swift we create `Extension` and `wrappers` around them. Applications using Swift language should at all times prefer to use the Swift properties and methods.

A major design rationale we have undertaken in Swift is to use reactive(Rx) programming paradigm to better leverage events and chaining whilst in Objective-C providing a simple closure blocked base syntax.

Reactive (Rx) programming provides a way for composing asynchronous and event-based streams which can be observed or chained together. A stream is a sequence of ongoing events ordered in time. It can emit three different things: a value (of some type), an error, or a "completed" signal. The SDK uses [https://github.com/ReactiveX/RxSwift](RxSwift) objects such as `Observables` and `Variable` object to help facilitate the use of reactive behaviour.

#### Observables and Observers
Two concepts to be aware of for this guide are the `Observable` and the `Observer`.
    - An `Observable` is something which emits notifications of change.
    - An `Observer` is something which subscribes to an Observable, in order to be notified when it has changed.
You can have multiple Observers listening to an Observable. This means that when the Observable changes, it will notify all its Observers.

Observing for change in client state i.e connected, sync etc.. To observe to an `Observable` object, we first have to call subscription or a high-order function like:

```swift
let client = ConversationClient.instance

// observe for changes in client state
client.state.asObservable().subscribe(onNext: { state in
    // new state
}).addDisposableTo(client.disposeBag)
```

The `.subscribe()` function allows developers to listen for the next result, errors and when it is complete

For Objective-c the following function would look like:

```swift
NXMConversationClient *client = [NXMConversationClient instance];

// observe for changes in client state    
[client stateObjc:^(enum NXMStateObjc state) {
    // new state
}]; 
```

Observing for change in conversation collection

```
// SDK
let client = ConversationClient.instance

client.conversation.conversations.asObservable.subscribe(onNext: { changes in
    switch changes {
    case .inserted(let conversations, let reason): break
    case .updated(let conversations): break
    case .deleted(let conversations): break
    }
}).addDisposableTo(client.disposeBag)
```

Chaining actions together i.e login, create conversation and than send a text event. Example of using Swift high order function to chain request together:  

```swift
let client = ConversationClient.instance

// send a text event
client
    .login(with: "TOKEN_HERE").asObservable()
    .flatMap { client.conversation.new("New conversation", withJoin: true).asObservable() }
    .do(onNext: { _ = $0.invite("User 2").subscribe() })
    .subscribe(onNext: { conversation in
        try? conversation.send("Hello World!")
    }).addDisposableTo(client.disposeBag)
```

The following will first login, after that has been successful it will create a new conversation with join, invite a new user and then send a text event.

#### Dispose bag: 
All subscription requires a dispose bag to be returned to the calling function to help with memory references counting in Swift. Dispose bags are used to return ARC like behaviour to RxSwift, when a DisposeBag is deallocated (i.e when parent object called deinit) it will call dispose on each of the added disposables.
 