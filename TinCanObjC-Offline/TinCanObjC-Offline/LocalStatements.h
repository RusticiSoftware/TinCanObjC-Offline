//
//  LocalStatements.h
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
