//
//  ConversationControllerObjectiveCTest.m
//  NexmoConversation
//
//  Created by Shams Ahmed on 01/02/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tests-Swift.h"

@import Quick;
@import Nimble;
@import NexmoConversation;

#define QUICK_DISABLE_SHORT_SYNTAX 1

QuickSpecBegin(ConversationControllerObjectiveCTest)

it(@"fetches all conversation for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    [client addAuthorizationWith:@"token"];

    [HTTPStubbingFactor fetchsAllConversationsWith: self from: 0];

    __block BOOL result = false;
    
    [client.conversation all:^(NSArray<NXMConversationPreviewModel *> * _Nonnull newConversations) {
        result = true;
    } onFailure:^(NSError * _Nonnull error) {
        XCTFail(@"");
    }];
    
    expect(result).toEventually(beTrue());
});

it(@"fails to fetch all conversation for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];

    [HTTPStubbingFactor fetchsAllConversationsErrorWith: self from: 0];
    
    __block NSError *error;
    
    [client.conversation all:^(NSArray<NXMConversationPreviewModel *> * _Nonnull newConversations) {
        XCTFail(@"");
    } onFailure:^(NSError * _Nonnull newError) {
        error = newError;
    }];

    expect(error.code).toEventually(equal(3));
});

it(@"fails to fetch all conversation with user id for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor fetchsAllConversationsErrorWith:self forUserId:@"usr-123"];
    
    __block NSError *error;
    
    [client.conversation allWith:@"usr-123" :^(NSArray<NXMConversationPreviewModel *> * _Nonnull newConversations) {
        XCTFail(@"");
    } onFailure:^(NSError * _Nonnull newError) {
        error = newError;
    }];
    
    expect(error.code).toEventually(equal(3));
});

it(@"fetches all conversation with user id for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    [client addAuthorizationWith:@"token"];

    [HTTPStubbingFactor fetchsAllConversationsWith:self forUserId:@"usr-123"];
    
    __block BOOL result = false;
    
    [client.conversation allWith:@"usr-123" :^(NSArray<NXMConversationPreviewModel *> * _Nonnull newConversations) {
        result = true;
    } onFailure:^(NSError * _Nonnull error) {
        XCTFail(@"");
    }];

    expect(result).toEventually(beTrue());
});

it(@"fails to fetch a conversation with id for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor conversationErrorWith:self forId:@"con-123"];
    
    __block NSError *error;
    
    [client.conversation conversationWith:@"con-123" :^(NXMConversation * _Nonnull conversation) {
        XCTFail(@"");
    } onFailure:^(NSError * _Nonnull newError) {
        error = newError;
    }];
    
    expect(error.code).toEventually(equal(3));
});

it(@"fetches a conversation with id for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];

    [HTTPStubbingFactor conversationWith:self forId:@"con-123"];
    
    __block BOOL result = false;
    
    [client.conversation conversationWith:@"con-123" :^(NXMConversation * _Nonnull conversation) {
        result = true;
    } onFailure:^(NSError * _Nonnull error) {
        XCTFail(@"");
    }];
    
    expect(result).toEventually(beTrue());
});

it(@"fails to join a conversation with uuid for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor joinErrorWith:self uuid:@"con-123"];
    
    __block NSError *error;
    
    [client.conversation joinWithUserId:@"usr-123" memberId:@"mem-123" uuid:@"con-123" :^(NSString * _Nonnull uuid) {
        XCTFail(@"");
    } onFailure:^(NSError * _Nonnull newError) {
        error = newError;
    }];
    
    expect(error.code).toEventually(equal(3));
});

it(@"joins a conversation with uuid for objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor joinWith:self uuid:@"con-123"];
    
    __block BOOL result = false;
    
    [client.conversation joinWithUserId:@"usr-123" memberId:@"mem-123" uuid:@"con-123" :^(NSString * _Nonnull uuid) {
        result = true;
    } onFailure:^(NSError * _Nonnull error) {
        XCTFail(@"");
    }];
    
    expect(result).toEventually(beTrue());
});

// conversation non-joined

it(@"fails to create a non-joined conversation with returned error on objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor createErrorWith:self];
    
    __block NSError *error;
    
    [client.conversation newWith:@"name" shouldJoin:false :^(NXMConversation * _Nonnull uuid) {
        XCTFail(@"");
    } onFailure:^(NSError * _Nonnull newError) {
        error = newError;
    } onComplete:^() {
        
    }];
    
    expect(error.domain.length).toEventually(beGreaterThan(3));
    expect(error).toEventuallyNot(beNil());
});

it(@"fails to create a non-joined conversation with objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor createWith:self];
    [HTTPStubbingFactor detailedConversationsWith:self for:@"CON-075e4e6a-d168-4c10-a29a-ccb29058c27c"];
    
    __block BOOL result = false;
    
    [client.conversation newWith:@"name" shouldJoin:false:^(NXMConversation * _Nonnull uuid) {
        result = true;
    } onFailure:^(NSError * _Nonnull error) {
        XCTFail(@"");
    } onComplete:^() {
    
    }];
    
    expect(result).withTimeout(5).toEventually(beFalse());
});

// new conversation with join

it(@"fails to create a joined conversation with returned error on objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor createErrorWith:self];
    
    __block NSError *error;

    [client.conversation newWith:@"name" shouldJoin:true :^(NXMConversation * _Nonnull uuid) {
        XCTFail(@"");
    } onFailure:^(NSError * _Nonnull newError) {
        error = newError;
    } onComplete:^() {
        
    }];

    expect(error.domain.length).toEventually(beGreaterThan(3));
    expect(error).toEventuallyNot(beNil());
});

it(@"creates a joined conversation on objective-c", ^{
    NXMConversationClient *client = [NXMConversationClient instance];
    
    [HTTPStubbingFactor detailedConversationsWith:self for:@"CON-075e4e6a-d168-4c10-a29a-ccb29058c27c"];
    [HTTPStubbingFactor joinWith:self uuid:@"CON-075e4e6a-d168-4c10-a29a-ccb29058c27c"];
    [HTTPStubbingFactor createWith:self];

    __block BOOL result = false;
    
    [client.conversation newWith:@"name" shouldJoin:true :^(NXMConversation * _Nonnull uuid) {
        result = true;
    } onFailure:^(NSError * _Nonnull error) {
        XCTFail(@"");
    } onComplete:^() {
        
    }];

    expect(result).withTimeout(5).toEventually(beTrue());
});

QuickSpecEnd
