//
//  LocalStatements.h
//  RSTCAPI
//
//  Created by Brian Rogers on 3/18/13.
//  Copyright (c) 2013 Rustici Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 Managed Object representing an offline TCStatement entry. These values are used when posted the persisted offline statement to the remote LRS.
 */
@interface LocalStatements : NSManagedObject
/** unique identifier for this statement */
@property (nonatomic, retain) NSString * statementId;
/** JSON string from the TCStatement object */
@property (nonatomic, retain) NSString * statementJson;
/** timestamp of database insert */
@property (nonatomic) NSDate * createDate;
/** timestamp of LRS post (in case delete does not happen) */
@property (nonatomic) NSDate * postedDate;
/** querystring to use for the statement POST/PUT */
@property (nonatomic, retain) NSString * querystring;

@end
