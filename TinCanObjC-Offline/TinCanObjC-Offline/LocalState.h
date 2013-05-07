//
//  LocalState.h
//  RSTCAPI
//
//  Created by Brian Rogers on 3/18/13.
//  Copyright (c) 2013 Brian Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalState : NSManagedObject

@property (nonatomic, retain) NSString * stateId;
@property (nonatomic, retain) NSString * stateContents;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) NSString * querystring;
@property (nonatomic, retain) NSString * activityId;
@property (nonatomic, retain) NSString * agentJson;

@end
