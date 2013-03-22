//
//  TinCanObjC_OfflineTests.m
//  TinCanObjC-OfflineTests
//
//  Created by Brian Rogers on 3/21/13.
//  Copyright (c) 2013 Rustici Software. All rights reserved.
//

#import "TinCanObjC_OfflineTests.h"

@interface TinCanObjC_OfflineTests()
{
    RSTinCanOfflineConnector *tincan;
}

@end

@implementation TinCanObjC_OfflineTests

- (void)setUp
{
    [super setUp];
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *lrs = [[NSMutableDictionary alloc] init];
    [lrs setValue:@"https://cloud.scorm.com/ScormEngineInterface/TCAPI/VK76L7KZME/sandbox" forKey:@"endpoint"];
    [lrs setValue:@"Basic Vks3Nkw3S1pNRTo3WTFETmM1bWFwYk5wckg5aE1KQmNaNTFUbWFGSXNvY1hnUlFjREtn" forKey:@"auth"];
    // just add one LRS for now
    [options setValue:[NSArray arrayWithObject:lrs] forKey:@"recordStore"];
    [options setValue:@"0.95" forKey:@"version"];
    tincan = [[RSTinCanOfflineConnector alloc]initWithOptions:options];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//- (void)testGetStoredStatements
//{
//    
//    NSMutableDictionary *statementOptions = [[NSMutableDictionary alloc] init];
//    [statementOptions setValue:@"http://tincanapi.com/test" forKey:@"activityId"];
//    [statementOptions setValue:[[TCVerb alloc] initWithId:@"http://adlnet.gov/expapi/verbs/experienced" withVerbDisplay:[[TCLocalizedValues alloc] initWithLanguageCode:@"en-US" withValue:@"experienced"]] forKey:@"verb"];
//    [statementOptions setValue:@"http://adlnet.gov/expapi/activities/course" forKey:@"activityType"];
//    TCStatement *statementToSend = [self createTestStatementWithOptions:statementOptions];
//    
//    //add a statement to the queue
//    //[tincan enqueueStatement:statementToSend];
//    //check to make sure there are some statements here
//    NSArray *statementArray = [tincan getCachedStatements];
//    NSLog(@"[statementArray count] : %d",[statementArray count]);
//    STAssertNotNil(statementArray, @"statementArray should not be null");
//    
//    [tincan sendOldestFromQueueWithCompletionBlock:^{
//        NSLog(@"statements flushed");
//        [[TestSemaphor sharedInstance] lift:@"flushStatements"];
//    }];
//    [[TestSemaphor sharedInstance] waitForKey:@"flushStatements"];
//}

@end
