//
//  NXMConversationClientTest.m
//  NexmoConversation
//
//  Created by Shams Ahmed on 02/11/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tests-Swift.h"

@import NexmoConversation;

@interface NXMConversationClientTest: XCTestCase

@end

@implementation NXMConversationClientTest

#pragma mark -
#pragma mark - Setup

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark -
#pragma mark - Test

- (void)testClientWorksInObjc {
    NXMConversationClient *client = [NXMConversationClient instance];
    
    XCTAssertNotNil(client, @"client is nil");
}

- (void)testClientCanReadBasicProperty {
    NXMConversationClient *client = [NXMConversationClient instance];
    
    XCTAssertNotNil(client, @"client is nil");
}

- (void)testAccountControllerActions {
    NXMConversationClient *client = [NXMConversationClient instance];
    
    XCTAssertNotNil(client.account, "controller is set to nil");
}

- (void)testConversationControllerActions {
    NXMConversationClient *client = [NXMConversationClient instance];
    
    XCTAssertNotNil(client.conversation, "controller is set to nil");
}

@end
