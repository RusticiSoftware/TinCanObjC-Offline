//
//  TCStatementCollection.h
//
//  Created by Brian Rogers on 3/7/13.
//
//  Copyright 2013 Rustici Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
