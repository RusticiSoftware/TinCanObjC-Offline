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
//    [lrs setValue:@"http://localhost:8080/ScormEngineInterface/TCAPI/" forKey:@"endpoint"];
//    [lrs setValue:@"Basic c3VwZXJ1c2VyOnN1cGVydXNlcg==" forKey:@"auth"];
    [lrs setValue:@"https://cloud.scorm.com/ScormEngineInterface/TCAPI/K5QNRA5J5J/sandbox" forKey:@"endpoint"];
    [lrs setValue:@"Basic SzVRTlJBNUo1Sjp2UFhLejBkd3pZM0gxQnEzZFIzVTNJc01DejBUN2Z5T0tVdE5TR3lm" forKey:@"auth"];
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
    // setup the variables we're using for this statement
    NSString *activityId = @"http://lifeway.com/video/223344334234234456";
    NSString *activityName = @"Sample Video Name";
    NSString *activityDescription = @"Sample Video Description";
    
    NSString *externalPackageId = @"";
    NSString *externalRegistrationId = @"";
    NSString *externalConfiguration = @"";
    
    NSNumber *videoDuration = [NSNumber numberWithInt:802.467];
    NSNumber *lastPosition = [NSNumber numberWithInt:102.342];
    
    NSString *registrationUUID = [TCUtil GetUUID];
    
    
    // build the actor
    TCAgent *actor = [[TCAgent alloc] initWithName:@"Brian Rogers" withMbox:@"mailto:brian@tincanapi.com"];
    

    // build the verb
    TCVerb *verb = [[TCVerb alloc] initWithId:@"http://adlnet.gov/expapi/verbs/attempted" withVerbDisplay:[[TCLocalizedValues alloc] initWithLanguageCode:@"und" withValue:@"attempted"]];
    
    
    // build the result
    NSMutableDictionary *resultExtensions = [[NSMutableDictionary alloc] init];
    [resultExtensions setValue:externalRegistrationId forKey:@"http://scorm.com/scorm-engine/externalRegistration"];
    [resultExtensions setValue:externalPackageId forKey:@"http://scorm.com/scorm-engine/externalPackage"];
    [resultExtensions setValue:externalConfiguration forKey:@"http://scorm.com/scorm-engine/externalConfiguration"];
    [resultExtensions setValue:videoDuration forKey:@"http://lifeway.com/brightcove-video/duration"];
    [resultExtensions setValue:lastPosition forKey:@"http://lifeway.com/brightcove-video/last-position"];
    
    TCResult *result = [[TCResult alloc] initWithResponse:nil withScore:nil withSuccess:[NSNumber numberWithBool:true] withCompletion:[NSNumber numberWithBool:true] withDuration:nil withExtensions:resultExtensions];
    
    
    // build the context
    NSMutableDictionary *contextActivities = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *groupingDict = [[NSMutableDictionary alloc] init];
    [groupingDict setValue:activityId forKey:@"id"];
    [groupingDict setValue:@"Activity" forKey:@"objectType"];
    NSArray *groupingArray = @[groupingDict];
    [contextActivities setValue:groupingArray forKey:@"grouping"];
    
    TCContext *context = [[TCContext alloc] initWithRegistration:registrationUUID withInstructor:nil withTeam:nil withContextActivities:contextActivities withExtensions:nil];

    
    // build the activity definition, extensions and the activity object
    NSMutableDictionary *objectExtensions = [[NSMutableDictionary alloc] init];
    [objectExtensions setValue:videoDuration forKey:@"http://lifeway.com/brightcove-video/duration"];
    
    TCActivityDefinition *actDef = [[TCActivityDefinition alloc] initWithName:[[TCLocalizedValues alloc] initWithLanguageCode:@"en-US" withValue:activityName]
                                                              withDescription:[[TCLocalizedValues alloc] initWithLanguageCode:@"en-US" withValue:activityDescription]
                                                                     withType:@"http://adlnet.gov/expapi/activities/course"
                                                               withExtensions:objectExtensions
                                                          withInteractionType:nil
                                                  withCorrectResponsesPattern:nil
                                                                  withChoices:nil
                                                                    withScale:nil
                                                                   withTarget:nil
                                                                    withSteps:nil];
    
    TCActivity *activity = [[TCActivity alloc] initWithId:activityId withActivityDefinition:actDef];
    

    

    
    TCStatement *statementToSend = [[TCStatement alloc] initWithId:[TCUtil GetUUID] withActor:actor withTarget:activity withVerb:verb withResult:result withContext:context];


    NSLog(@"statementToSend JSON - %@", [statementToSend JSONString]);
    

    
    //add a statement to the queue
//    [ enqueueStatement:statementToSend withCompletionBlock:^{
//        NSLog(@"statement enqued");
//    }withErrorBlock:^(NSError *error){
//        NSLog(@"error : %@", [error userInfo]);
//    }];
//    //check to make sure there are some statements here
//    NSArray *statementArray = [tincan getCachedStatements];
//    NSLog(@"[statementArray count] : %d",[statementArray count]);
//    STAssertNotNil(statementArray, @"statementArray should not be null");
//    
//    [tincan sendAllStatementsToServerWithCompletionBlock:^{
//        NSLog(@"statements flushed");
//        [[TestSemaphor sharedInstance] lift:@"flushStatements"];
//    }withErrorBlock:^(NSError *error){
//        STFail(@"error : %@", [error userInfo]);
//        [[TestSemaphor sharedInstance] lift:@"flushStatements"];
//    }];
    
    //[[TestSemaphor sharedInstance] waitForKey:@"flushStatements"];
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
    
    TCResult *result = [options valueForKey:@"result"];
    
    TCContext *context = [options valueForKey:@"context"];
    
    TCStatement *statementToSend = [[TCStatement alloc] initWithId:[TCUtil GetUUID] withActor:actor withTarget:activity withVerb:verb withResult:result withContext:context];
    
    return statementToSend;
}

//- (void) testOfflineState
//{
//    TCAgent *actor = [[TCAgent alloc] initWithName:@"Brian Rogers" withMbox:@"mailto:brian@tincanapi.com"];
//    
//    NSMutableDictionary *stateContents = [[NSMutableDictionary alloc] init];
//    [stateContents setValue:@"page 1" forKey:@"bookmark"];
//    
//    NSString *stateId = [TCUtil GetUUID];
//    
//    // put some state
//    [tincan setStateWithValue:[stateContents copy] withStateId:stateId withActivityId:[TCUtil encodeURL:@"http://tincanapi.com/test"] withAgent:actor withRegistration:nil withOptions:nil withCompletionBlock:^{
//        [[TestSemaphor sharedInstance] lift:@"saveState"];
//    }withErrorBlock:^(NSError *error){
//        [[TestSemaphor sharedInstance] lift:@"saveState"];
//    }];
//    [[TestSemaphor sharedInstance] waitForKey:@"saveState"];
//    
//    [tincan sendLocalStateToServerWithCompletionBlock:^{
//        NSLog(@"sent all or 50 records");
//        [[TestSemaphor sharedInstance] lift:@"sendState"];
//    }withErrorBlock:^(NSError *error){
//        NSLog(@"error : %@", [error userInfo]);
//        [[TestSemaphor sharedInstance] lift:@"sendState"];
//    }];
//    [[TestSemaphor sharedInstance] waitForKey:@"sendState"];
//    
//    //26CE7504-C478-44FA-96AF-3332E561EE7B
//    [tincan getStateFromServerWithStateId:@"26CE7504-C478-44FA-96AF-3332E561EE7B" withActivityId:[TCUtil encodeURL:@"http://tincanapi.com/test"] withAgent:actor withRegistration:nil withOptions:nil withCompletionBlock:^(NSDictionary *state){
//        NSLog(@"got state from server : %@", state);
//        [[TestSemaphor sharedInstance] lift:@"getState"];
//    }withErrorBlock:^(TCError *error){
//        
//    }];
//    [[TestSemaphor sharedInstance] waitForKey:@"getState"];
//}

//- (void) testGetLocalState
//{
//    TCAgent *actor = [[TCAgent alloc] initWithName:@"Brian Rogers" withMbox:@"mailto:brian@tincanapi.com"];
//    
//    NSMutableDictionary *stateContents = [[NSMutableDictionary alloc] init];
//    [stateContents setValue:@"page 1" forKey:@"bookmark"];
//    
//    NSString *stateId = [TCUtil GetUUID];
//    
//    // put some state
//    [tincan setStateWithValue:[stateContents copy] withStateId:stateId withActivityId:[TCUtil encodeURL:@"http://tincanapi.com/test"] withAgent:actor withRegistration:nil withOptions:nil withCompletionBlock:^{
//        [[TestSemaphor sharedInstance] lift:@"saveState"];
//    }withErrorBlock:^(NSError *error){
//        [[TestSemaphor sharedInstance] lift:@"saveState"];
//    }];
//    [[TestSemaphor sharedInstance] waitForKey:@"saveState"];
//    
//    [tincan getLocalStateForStateId:stateId withCompletionBlock:^(NSDictionary *state) {
//        NSLog(@"%@", state);
//    }];
//}

//- (void) testSendLocalState
//{
//    [tincan sendLocalStateToServerWithCompletionBlock:^{
//        NSLog(@"sent all or 50 records");
//        [[TestSemaphor sharedInstance] lift:@"sendState"];
//    }withErrorBlock:^(NSError *error){
//        NSLog(@"error : %@", [error userInfo]);
//        [[TestSemaphor sharedInstance] lift:@"sendState"];
//    }];
//    [[TestSemaphor sharedInstance] waitForKey:@"sendState"];
//}

@end
