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
    [lrs setValue:@"http://localhost:8080/ScormEngineInterface/TCAPI/" forKey:@"endpoint"];
    [lrs setValue:@"Basic c3VwZXJ1c2VyOnN1cGVydXNlcg==" forKey:@"auth"];
    [lrs setValue:@"1.0.0" forKey:@"version"];
    // just add one LRS for now
    [options setValue:[NSArray arrayWithObject:lrs] forKey:@"recordStore"];
    tincan = [[RSTinCanOfflineConnector alloc]initWithOptions:options];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testOfflineStatements
{
    
    NSMutableDictionary *statementOptions = [[NSMutableDictionary alloc] init];
    [statementOptions setValue:@"http://tincanapi.com/test" forKey:@"activityId"];
    [statementOptions setValue:[[TCVerb alloc] initWithId:@"http://adlnet.gov/expapi/verbs/experienced" withVerbDisplay:[[TCLocalizedValues alloc] initWithLanguageCode:@"en-US" withValue:@"experienced"]] forKey:@"verb"];
    [statementOptions setValue:@"http://adlnet.gov/expapi/activities/course" forKey:@"activityType"];
    TCStatement *statementToSend = [self createTestStatementWithOptions:statementOptions];
    
    //add a statement to the queue
    [tincan enqueueStatement:statementToSend withCompletionBlock:^{
        NSLog(@"statement enqued");
    }withErrorBlock:^(NSError *error){
        NSLog(@"error : %@", [error userInfo]);
    }];
    //check to make sure there are some statements here
    NSArray *statementArray = [tincan getCachedStatements];
    NSLog(@"[statementArray count] : %d",[statementArray count]);
    STAssertNotNil(statementArray, @"statementArray should not be null");
    
    [tincan sendOldestStatementFromQueueWithCompletionBlock:^{
        NSLog(@"statements flushed");
        [[TestSemaphor sharedInstance] lift:@"flushStatements"];
    }];
    [[TestSemaphor sharedInstance] waitForKey:@"flushStatements"];
}

- (TCStatement *)createTestStatementWithOptions:(NSDictionary *)options
{
    TCAgent *actor = [[TCAgent alloc] initWithName:@"Brian Rogers" withMbox:@"mailto:brian@tincanapi.com"];
    
    TCActivityDefinition *actDef = [[TCActivityDefinition alloc] initWithName:[[TCLocalizedValues alloc] initWithLanguageCode:@"en-US" withValue:@"http://tincanapi.com/test"]
                                                              withDescription:[[TCLocalizedValues alloc] initWithLanguageCode:@"en-US" withValue:@"Description for test statement"]
                                                                     withType:[options valueForKey:@"activityType"]
                                                               withExtensions:nil
                                                          withInteractionType:nil
                                                  withCorrectResponsesPattern:nil
                                                                  withChoices:nil
                                                                    withScale:nil
                                                                   withTarget:nil
                                                                    withSteps:nil];
    
    TCActivity *activity = [[TCActivity alloc] initWithId:[options valueForKey:@"activityId"] withActivityDefinition:actDef];
    
    TCVerb *verb = [options valueForKey:@"verb"];
    
    TCStatement *statementToSend = [[TCStatement alloc] initWithId:[TCUtil GetUUID] withActor:actor withTarget:activity withVerb:verb];
    
    return statementToSend;
}

- (void) testOfflineState
{
    TCAgent *actor = [[TCAgent alloc] initWithName:@"Brian Rogers" withMbox:@"mailto:brian@tincanapi.com"];
    
    NSMutableDictionary *stateContents = [[NSMutableDictionary alloc] init];
    [stateContents setValue:@"page 1" forKey:@"bookmark"];
    
    NSString *stateId = [TCUtil GetUUID];
    
    // put some state
    [tincan setStateWithValue:[stateContents copy] withStateId:stateId withActivityId:[TCUtil encodeURL:@"http://tincanapi.com/test"] withAgent:actor withRegistration:nil withOptions:nil withCompletionBlock:^{
        [[TestSemaphor sharedInstance] lift:@"saveState"];
    }withErrorBlock:^(NSError *error){
        [[TestSemaphor sharedInstance] lift:@"saveState"];
    }];
    [[TestSemaphor sharedInstance] waitForKey:@"saveState"];
}

- (void) testSendLocalState
{
    [tincan sendLocalStateToServerWithCompletionBlock:^{
        NSLog(@"sent all or 50 records");
        [[TestSemaphor sharedInstance] lift:@"sendState"];
    }withErrorBlock:^(NSError *error){
        NSLog(@"error : %@", [error userInfo]);
        [[TestSemaphor sharedInstance] lift:@"sendState"];
    }];
    [[TestSemaphor sharedInstance] waitForKey:@"sendState"];
}

@end
