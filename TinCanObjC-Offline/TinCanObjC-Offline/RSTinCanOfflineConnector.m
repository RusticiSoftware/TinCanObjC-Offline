//
//  RSTinCanConnector.m
//  RSTCAPI
//
//  Created by Brian Rogers on 2/28/13.
//  Copyright (c) 2013 Brian Rogers. All rights reserved.
//

#import "RSTinCanOfflineConnector.h"


@interface RSTinCanOfflineConnector()
{
    NSMutableArray *_recordStore;
    NSMutableArray *_stateToDelete;
}
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@end

@implementation RSTinCanOfflineConnector

- (id) initWithOptions:(NSDictionary *)options
{
    if ((self = [super init])) {
        _recordStore = [options valueForKey:@"recordStore"];
        NSLog(@"recordStore %@", _recordStore);
        
    }
    return self;
}


/**
 Calls saveStatement on each configured LRS, provide callback to make it asynchronous
 
 @method sendStatement
 @param {TinCan.Statement|Object} statement Send statement to LRS
 @param {Function} [callback] Callback function to execute on completion
 */
- (void) sendStatementToServer:(TCStatement *)statementToSend withCompletionBlock:(void (^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock
{
    TCLRS *lrs = [[TCLRS alloc] initWithOptions:[_recordStore objectAtIndex:0]];
    
    [lrs saveStatement:statementToSend withOptions:nil
     withCompletionBlock:^(){
         //dispatch_async(dispatch_get_main_queue(), ^{
         NSLog(@"statement sent");
             completionBlock();
         //});
     }
      withErrorBlock:^(TCError *error){
          //dispatch_async(dispatch_get_main_queue(), ^{
              errorBlock(error);
          //});
      }];
}

/**
 Calls retrieveStatement on each configured LRS until it gets a result, provide callback to make it asynchronous
 
 @method getStatement
 @param {String} statement Statement ID to get
 @param {Function} [callback] Callback function to execute on completion
 @return {TinCan.Statement} Retrieved statement from LRS
 
 TODO: make TinCan track statements it has seen in a local cache to be returned easily
 */
- (void) getStatementWithId:(NSString *)statementId withOptions:(NSDictionary *)options withCompletionBlock:(void(^)(TCStatement *))completionBlock withErrorBlock:(void(^)(TCError *))errorBlock
{
    
    TCLRS *lrs = [[TCLRS alloc] initWithOptions:[_recordStore objectAtIndex:0]];
    
    [lrs retrieveStatementWithId:statementId withOptions:options
        withCompletionBlock:^(TCStatement *statement){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(statement);
            });
        }
         withErrorBlock:^(TCError *error){
             dispatch_async(dispatch_get_main_queue(), ^{
                 errorBlock(error);
             });
         }];
}

/**
 Calls saveStatements with list of prepared statements
 
 @method sendStatements
 @param {Array} Array of statements to send
 @param {Function} Callback function to execute on completion
 */
- (void) sendStatementsToServer:(TCStatementCollection *)statementArray withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock
{
    TCLRS *lrs = [[TCLRS alloc] initWithOptions:[_recordStore objectAtIndex:0]];
    
    [lrs saveStatements:statementArray withOptions:nil
    withCompletionBlock:^(){
       dispatch_async(dispatch_get_main_queue(), ^{
           completionBlock();
       });
    }
    withErrorBlock:^(TCError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock(error);
        });
    }];
}

/**
 @method getStatements
 @param {Object} [cfg] Configuration for request
 @param {Boolean} [cfg.sendActor] Include default actor in query params
 @param {Boolean} [cfg.sendActivity] Include default activity in query params
 @param {Object} [cfg.params] Parameters used to filter
 
 @param {Function} [cfg.callback] Function to run at completion
 
 TODO: support multiple LRSs and flag to use single
 */
- (void) getStatementsFromServerWithOptions:(TCQueryOptions *)options withCompletionBlock:(void(^)(NSArray *))completionBlock withErrorBlock:(void(^)(TCError *))errorBlock
{
    TCLRS *lrs = [[TCLRS alloc] initWithOptions:[_recordStore objectAtIndex:0]];
    
    [lrs queryStatementsWithOptions:options
        withCompletionBlock:^(NSArray *statementArray){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(statementArray);
            });
        }
        withErrorBlock:^(TCError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
    }];
}

/**
 @method getState
 @param {String} key Key to retrieve from the state
 @param {Object} [cfg] Configuration for request
 @param {Object} [cfg.agent] Agent used in query,
 defaults to 'actor' property if empty
 @param {Object} [cfg.activity] Activity used in query,
 defaults to 'activity' property if empty
 @param {Object} [cfg.registration] Registration used in query,
 defaults to 'registration' property if empty
 @param {Function} [cfg.callback] Function to run with state
 */
- (void) getStateFromServerWithStateId:(NSString *)stateId withActivityId:(NSString *)activityId withAgent:(TCAgent *)agent withRegistration:(NSString *)registration withOptions:(NSDictionary *)options withCompletionBlock:(void(^)(NSDictionary *))completionBlock withErrorBlock:(void(^)(TCError *))errorBlock
{
    TCLRS *lrs = [[TCLRS alloc] initWithOptions:[_recordStore objectAtIndex:0]];
    
    [lrs retrieveStateWithStateId:stateId withActivityId:activityId withAgent:agent withRegistration:registration withOptions:options
        withCompletionBlock:^(NSDictionary *state)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(state);
            });
        }
         withErrorBlock:^(TCError *error){
             dispatch_async(dispatch_get_main_queue(), ^{
                 errorBlock(error);
             });
         }];
}

/**
 @method setState
 @param {String} key Key to store into the state
 @param {String|Object} val Value to store into the state, objects will be stringified to JSON
 @param {Object} [cfg] Configuration for request
 @param {Object} [cfg.agent] Agent used in query,
 defaults to 'actor' property if empty
 @param {Object} [cfg.activity] Activity used in query,
 defaults to 'activity' property if empty
 @param {Object} [cfg.registration] Registration used in query,
 defaults to 'registration' property if empty
 @param {Function} [cfg.callback] Function to run with state
 */
- (void) setStateWithValue:(NSDictionary *)value withStateId:(NSString *)stateId withActivityId:(NSString *)activityId withAgent:(TCAgent *)agent withRegistration:(NSString *)registration withOptions:(NSDictionary *)options withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(TCError *))errorBlock
{
    _managedObjectContext = [TCOfflineDataManager sharedInstance].mainObjectContext;
    
    TCState *state = [[TCState alloc] initWithContents:value withStateId:stateId withActivityId:activityId withAgent:agent withRegistration:registration];
    
    LocalState *newState = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"LocalState"
                                     inManagedObjectContext:_managedObjectContext];
    [newState setCreateDate:[NSDate date]];
    [newState setStateId:stateId];
    [newState setStateContents:[NSString stringWithFormat:@"%@",[state JSONString]]];
    [newState setQuerystring:state.querystring];
    [newState setActivityId:activityId];
    [newState setAgentJson:[agent JSONString]];
    
    NSLog(@"saving to coredata");
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        errorBlock((TCError *)error);
    }else{
        NSLog(@"statement added to localstorage");
        completionBlock();
    }
    

}

- (void) enqueueStatement:(TCStatement *)statement withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock
{
    NSLog(@"enquing Statement %@", [statement JSONString]);
    TCOfflineStatementCollection *statementQueue = [[TCOfflineStatementCollection alloc] init];
    
    [statementQueue addStatement:statement withCompletionBlock:completionBlock withErrorBlock:errorBlock];
}

- (NSArray *) getCachedStatements
{
    TCOfflineStatementCollection *statementQueue = [[TCOfflineStatementCollection alloc] init];
    return [statementQueue getCachedStatements];
}

- (void) sendOldestStatementFromQueueWithCompletionBlock:(void(^)())completionBlock
{
    TCOfflineStatementCollection *statementQueue = [[TCOfflineStatementCollection alloc] init];
    NSArray *unsentStatements = [statementQueue getUnsentStatements:1];
    //NSLog(@"statement json %@", [[unsentStatements objectAtIndex:0] statementJson]);
    TCStatement *statementToSend = [[TCStatement alloc] initWithJSON:[[unsentStatements objectAtIndex:0] statementJson]];
    NSLog(@"parsed statement %@", [statementToSend JSONString]);
    [self sendStatementToServer:statementToSend withCompletionBlock:^{
        [statementQueue markStatementPosted:statementToSend];
        completionBlock();
    }withErrorBlock:^(NSError *error)
    {
        NSLog(@"error sendOldestFromQueueWithCompletionBlock : %@",[error userInfo]);
    }];
}

- (void) sendAllStatementsToServerWithCompletionBlock:(void(^)())completionBlock withErrorBlock:(void (^)(NSError *))errorBlock
{
    TCOfflineStatementCollection *statementQueue = [[TCOfflineStatementCollection alloc] init];
    NSArray *unsentStatements = [statementQueue getUnsentStatements:500];
    NSLog(@"sending %li statements to server", (unsigned long)unsentStatements.count);
    TCStatementCollection *statementCollectionToSend = [[TCStatementCollection alloc] init];
    NSMutableArray *statementsToDelete = [[NSMutableArray alloc] init];
    
    for (LocalStatements *localStatement in unsentStatements) {

        TCStatement *statementToSend = [[TCStatement alloc] initWithJSON:[localStatement statementJson]];

        [statementCollectionToSend addStatement:statementToSend];
        [statementsToDelete addObject:statementToSend];

    }
    
    [self sendStatementsToServer:statementCollectionToSend withCompletionBlock:^{
        NSLog(@"statement batch sent");
        for (TCStatement *statementSent in statementsToDelete) {
            [statementQueue markStatementPosted:statementSent];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock();
        });
    }withErrorBlock:^(TCError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock(error);
        });
    }];
    
    
    
}

- (void) sendLocalStateToServerWithCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock
{
    // get the most recent distinct rows and send them
    NSLog(@"getting statement list");
    _managedObjectContext = [TCOfflineDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalState"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:50]; //send 50 rows for now just to take it easy. this may need to be called multiple times.
    
    NSError *error = nil;
    NSArray *fetchResults = [_managedObjectContext
                             executeFetchRequest:fetchRequest
                             error:&error];
    
    _stateToDelete = [[NSMutableArray alloc] init];
    
    if(error){
        NSLog(@"error - %@", error);
        errorBlock(error);
    }else{
        [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){

            //NSLog(@"%@", obj);
            __block LocalState *stateFromDb = (LocalState *)obj;
            TCLRS *lrs = [[TCLRS alloc] initWithOptions:[_recordStore objectAtIndex:0]];

            NSError *error;
            NSDictionary *stateDocument = [NSJSONSerialization JSONObjectWithData:[stateFromDb.stateContents dataUsingEncoding:NSStringEncodingConversionAllowLossy] options:kNilOptions error:&error];
            
            if (error) {
                errorBlock(error);
            }else{
                [_stateToDelete addObject:stateFromDb];

                [lrs saveStateWithValue:stateDocument withStateId:stateFromDb.stateId withActivityId:stateFromDb.activityId withAgent:[[TCAgent alloc] initWithJSON:stateFromDb.agentJson] withRegistration:nil withLastSHA1:nil withOptions:nil withCompletionBlock:^(){
                        
                    }
                     withErrorBlock:^(TCError *error){
                         dispatch_async(dispatch_get_main_queue(), ^{
                             errorBlock(error);
                         });
                     }];
            }
        }];
        
        [self deleteSendStateRowsWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }];
        
        
    }
}

- (void)deleteSendStateRowsWithCompletionBlock:(void(^)())completionBlock
{
    
    NSLog(@"state to delete count %li", (unsigned long)_stateToDelete.count);
    
    NSError *error;

    for (LocalState *stateRow in _stateToDelete) {
        [_managedObjectContext deleteObject:stateRow];
    }
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        completionBlock();
    }else{
        NSLog(@"************* deleted state");
        [_stateToDelete removeAllObjects];
        completionBlock();
    }
}

@end










