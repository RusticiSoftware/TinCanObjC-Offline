//
//  LocalState.h
//  RSTCAPI
//
//  Created by Brian Rogers on 3/18/13.
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
#import <CoreData/CoreData.h>

/**
 Managed Object representing an offline TinCan State entry. These values are used when posted the persisted offline state to the remote LRS.
 */
@interface LocalState : NSManagedObject

/** unique stateId for this entry */
@property (nonatomic, retain) NSString * stateId;
/** JSON representation of the state document value */
@property (nonatomic, retain) NSString * stateContents;
/** timestamp of database insert */
@property (nonatomic, retain) NSDate * createDate;
/** timestamp of when the record was posted (in case it does not get deleted on post) */
@property (nonatomic, retain) NSDate * postDate;
/** querystring to use for the PUT of the state to the server */
@property (nonatomic, retain) NSString * querystring;
/** activityId for this state entry */
@property (nonatomic, retain) NSString * activityId;
/** agentJson string for this state entry */
@property (nonatomic, retain) NSString * agentJson;

@end
