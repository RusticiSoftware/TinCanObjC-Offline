//
//  LocalStatements.h
//  RSTCAPI
//
//  Created by Brian Rogers on 3/18/13.
//  Copyright (c) 2013 Brian Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalStatements : NSManagedObject

@property (nonatomic, retain) NSString * statementId;
@property (nonatomic, retain) NSString * statementJson;
@property (nonatomic) NSDate * createDate;
@property (nonatomic) NSDate * postedDate;
@property (nonatomic, retain) NSString * querystring;

@end
