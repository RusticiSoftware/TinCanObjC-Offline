//
//  TCStatementCollection.h
//  RSTCAPI
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Brian Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCStatement.h"
#import "TCOfflineDataManager.h"
#import "LocalStatements.h"
#import "LocalState.h"

@interface TCOfflineStatementCollection : NSObject

- (id) init;

- (void) addStatement:(TCStatement *)statement;

- (NSString *)JSONString;

- (NSArray *) getCachedStatements;

-(NSArray *) getUnsentStatements:(int)limit;

- (void) markStatementPosted:(TCStatement *)statementPosted;

@end
