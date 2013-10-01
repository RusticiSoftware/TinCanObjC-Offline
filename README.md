TinCanObjC-Offline
==================

Offline wrapper for TinCanObjC


##Creating a RSTinCanOfflineConnector

    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *lrs = [[NSMutableDictionary alloc] init];
    [lrs setValue:@"https://your.lrs" forKey:@"endpoint"];
    [lrs setValue:@"Basic mHjdyhUudhjryr7486ryHhdjsjhuuetyhgksiI*8usijdh" forKey:@"auth"];
    [lrs setValue:@"1.0.0" forKey:@"version"];
    // just add one LRS for now
    [options setValue:[NSArray arrayWithObject:lrs] forKey:@"recordStore"];
    tincan = [[RSTinCanOfflineConnector alloc]initWithOptions:options];

##Creating and storing/sending a statement

	// setup the variables we're using for this statement
    NSString *activityId = @"http://something.com/video/223344334234234456";
    NSString *activityName = @"Sample Video Name";
    NSString *activityDescription = @"Sample Video Description";
	
    NSString *externalPackageId = @"";
    NSString *externalRegistrationId = @"";
    NSString *externalConfiguration = @"";
	
    NSNumber *videoDuration = [NSNumber numberWithInt:802.467];
    NSNumber *lastPosition = [NSNumber numberWithInt:102.342];
	
    NSString *registrationUUID = [TCUtil GetUUID];
	
    // build the actor
    TCAgent *actor = [[TCAgent alloc] initWithName:@"Joe User" withMbox:@"mailto:joe.user@tincanapi.com"];
	
    // build the verb
    TCVerb *verb = [[TCVerb alloc] initWithId:@"http://adlnet.gov/expapi/verbs/attempted" withVerbDisplay:[[TCLocalizedValues alloc] initWithLanguageCode:@"und" withValue:@"attempted"]];
	
    // build the result
    NSMutableDictionary *resultExtensions = [[NSMutableDictionary alloc] init];
    [resultExtensions setValue:externalRegistrationId forKey:@"http://scorm.com/scorm-engine/externalRegistration"];
    [resultExtensions setValue:externalPackageId forKey:@"http://scorm.com/scorm-engine/externalPackage"];
    [resultExtensions setValue:externalConfiguration forKey:@"http://scorm.com/scorm-engine/externalConfiguration"];
    [resultExtensions setValue:videoDuration forKey:@"http://somewhere.com/brightcove-video/duration"];
    [resultExtensions setValue:lastPosition forKey:@"http://somewhere.com/brightcove-video/last-position"];
	
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
    [objectExtensions setValue:videoDuration forKey:@"http://somewhere.com/brightcove-video/duration"];
	
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
	
	// add a statement to the queue
	[ enqueueStatement:statementToSend withCompletionBlock:^{
       NSLog(@"statement enqued");
	}withErrorBlock:^(NSError *error){
       NSLog(@"error : %@", [error userInfo]);
	}];
	//check to make sure there are some statements here
	NSArray *statementArray = [tincan getCachedStatements];
	NSLog(@"[statementArray count] : %d",[statementArray count]);
	STAssertNotNil(statementArray, @"statementArray should not be null");
	
	[tincan sendAllStatementsToServerWithCompletionBlock:^{
       NSLog(@"statements flushed");
       [[TestSemaphor sharedInstance] lift:@"flushStatements"];
	}withErrorBlock:^(NSError *error){
       STFail(@"error : %@", [error userInfo]);
       [[TestSemaphor sharedInstance] lift:@"flushStatements"];
	}];
	
    [[TestSemaphor sharedInstance] waitForKey:@"flushStatements"];