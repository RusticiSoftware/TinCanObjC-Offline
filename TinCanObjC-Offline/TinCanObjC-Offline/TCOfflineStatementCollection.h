//
//  TCStatementCollection.h
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Rustici Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCStatement.h"
#import "TCOfflineDataManager.h"
#import "LocalStatements.h"
#import "LocalState.h"

/**
 
 */
@interface TCOfflineStatementCollection : NSObject

/**
 
 @method init
 
 */
- (id) init;

/**
 
 @method addStatement
 @param statement The TCStatement to add to the collection
 @param completionBlock The code block to execute on completion
 @param errorBlock The code block to execute on error
 */
- (void) addStatement:(TCStatement *)statement withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock;
/**
 
 @method JSONString
 @returns jsonString NSString containing the JSON representation of this collection
 */
- (NSString *)JSONString;
/**
 
 @method getCachedStatements
 @returns cachedStatements NSArray containing the OfflineStatement objects cached
 */
- (NSArray *) getCachedStatements;
/**
 
 @method getUnsentStatements
 @param limit The limit of unsent statements to get
 */
-(NSArray *) getUnsentStatements:(int)limit;
/**
 
 @method markStatementPosted
 @param statementPosted The TCStatement that was posted
 */
- (void) markStatementPosted:(TCStatement *)statementPosted;

@end
