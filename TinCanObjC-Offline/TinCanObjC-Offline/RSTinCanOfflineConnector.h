//
//  RSTinCanOfflineConnector.h
//
//  Created by Brian Rogers on 2/28/13.
//  Copyright (c) 2013 RusticiSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCError.h"
#import "TCStatement.h"
#import "TCOfflineStatementCollection.h"
#import "TCLRS.h"
#import "TCQueryOptions.h"
#import "TCAgent.h"
#import "TCResult.h"

/**
 The front line connector for persisting tincan statements and state while offline and posting to your LRS when connected. This connector acts as a passthrough for the TinCanObjC library and wraps it with offline functionality.
 
 */
@interface RSTinCanOfflineConnector : NSObject


/**
 Calls initWithOptions with a configured LRS
 
 @method initWithOptions
 @param options containing LRS endpoint information
 */

- (id) initWithOptions:(NSDictionary *)options;


/**
 Calls saveStatement on each configured LRS, provide callback to make it asynchronous
 
 @method sendStatementToServer
 @param statementToSend statement Send statement to LRS
 @param completionBlock code to execute on completion
 @param errorBlock code to execute on error
 */
- (void) sendStatementToServer:(TCStatement *)statementToSend withCompletionBlock:(void (^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;

/**
 Calls retrieveStatement on each configured LRS until it gets a result, provide callback to make it asynchronous
 
 @method getStatement
 @param statementId Statement ID to get.
 @param options Options to use for the call.
 @param completionBlock Callback function to execute on completion.
 @param errorBlock Callback function to execute on error.
 
 */
- (void) getStatementWithId:(NSString *)statementId withOptions:(NSDictionary *)options withCompletionBlock:(void(^)(TCStatement *))completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;

/**
 Calls saveStatements with list of prepared statements
 
 @method sendStatementsToServer
 @param statementArray Array of statements to send
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) sendStatementsToServer:(TCStatementCollection *)statementArray withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;

/**
 Gets the statements from the LRS
 
 @method getStatementsFromServerWithOptions
 @param options TCQueryOptions for this statement query
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) getStatementsFromServerWithOptions:(TCQueryOptions *)options withCompletionBlock:(void(^)(NSArray *))completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;

/**
 Gets the state from the remote LRS filtered by provided stateId.
 
 @method getStateFromServerWithStateId
 @param stateId The stateId ot the state to retrieve from the LRS.
 @param activityId The activityId to use for the query
 @param agent The agent to use for the query
 @param registration The registration to use for the query
 @param options Additional options to pass to the query
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) getStateFromServerWithStateId:(NSString *)stateId withActivityId:(NSString *)activityId withAgent:(TCAgent *)agent withRegistration:(NSString *)registration withOptions:(NSDictionary *)options withCompletionBlock:(void(^)(NSDictionary *))completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;

/**
 @method getLocalStateForStateId
 @param stateId The stateId to retrieve.
 @param completionBlock The code to execute on completion.
 */
- (void) getLocalStateForStateId:(NSString *)stateId withCompletionBlock:(void(^)(NSDictionary *))completionBlock;

/**
 @method setState
 @param value The value/docment to save for this state entry
 @param stateId The stateId to use for this entry
 @param activityId The activityId to use for this entry
 @param agent The TCAgent to use for this entry
 @param registration The optional registration string for this entry
 @param options The options dictionary for this request
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) setStateWithValue:(NSDictionary *)value withStateId:(NSString *)stateId withActivityId:(NSString *)activityId withAgent:(TCAgent *)agent withRegistration:(NSString *)registration withOptions:(NSDictionary *)options withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;

/**
 @method deleteState
 @param stateId The stateId to use for this deletion
 @param activityId The activityId to use for this deletion
 @param agent The TCAgent to use for this deletion
 @param registration The optional registration string for this deletion
 @param options The options dictionary for this deletion
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) deleteStateWithStateId:(NSString *)stateId withActivityId:(NSString *)activityId withAgent:(TCAgent *)agent withRegistration:(NSString *)registration withOptions:(NSDictionary *)options withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock;


/**
 @method enqueueStatement
 @param statement The TCStatement to enqueue
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) enqueueStatement:(TCStatement *)statement withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock;

/**
 
 @method getCachedStatements
 @return statementArray NSArray containing OfflineStatement objects
 */
- (NSArray *) getCachedStatements;

/**
 
 
 @method sendOldestStatementFromQueueWithCompletionBlock
 @param completionBlock Callback function to execute on completion
 */
- (void) sendOldestStatementFromQueueWithCompletionBlock:(void(^)())completionBlock;

/**
 
 @method sendAllStatementsToServerWithCompletionBlock
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) sendAllStatementsToServerWithCompletionBlock:(void(^)())completionBlock withErrorBlock:(void (^)(NSError *))errorBlock;
/**
 
 @method sendLocalStateToServerWithCompletionBlock
 @param completionBlock Callback function to execute on completion
 @param errorBlock Callback function to execute on error
 */
- (void) sendLocalStateToServerWithCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock;

/**

 @method deleteSendStateRowsWithCompletionBlock
 @param completionBlock Callback function to execute on completion
 */
- (void)deleteSendStateRowsWithCompletionBlock:(void(^)())completionBlock;

@end