//
//  TCStatementCollection.m
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

#import "TCOfflineStatementCollection.h"

@interface TCOfflineStatementCollection()
{
    NSMutableArray *_statementArray;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;



@end

@implementation TCOfflineStatementCollection

- (id) init
{
    _statementArray = [[NSMutableArray alloc] init];
    return self;
}

- (void) addStatement:(TCStatement *)statement withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock
{
    [_statementArray addObject:[statement dictionary]];
    _managedObjectContext = [TCOfflineDataManager sharedInstance].mainObjectContext;
    LocalStatements *newStatement = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"LocalStatement"
                                   inManagedObjectContext:_managedObjectContext];
    [newStatement setCreateDate:[NSDate date]];
    [newStatement setStatementJson:[statement JSONString]];
    [newStatement setQuerystring:@""];
    [newStatement setStatementId:statement.statementId];
    
    NSLog(@"saving to coredata");
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        errorBlock(error);
    }else{
        NSLog(@"statement added to localstorage");
        completionBlock();
    }
}

- (NSString *)JSONString
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_statementArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[TCUtil stringByRemovingControlCharacters:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    return jsonString;
}

-(NSArray *) getCachedStatements
{
    NSLog(@"getting statement list");
    _managedObjectContext = [TCOfflineDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalStatement"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    //[fetchRequest setFetchLimit:10];
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
    //                                        initWithKey:@"updateDate"
    //                                        ascending:NO];
    //    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchResults = [_managedObjectContext
                             executeFetchRequest:fetchRequest
                             error:&error];
    NSLog(@"error - %@", error);
    //NSLog(@"results - %@",fetchResults);
    return fetchResults;
}

-(NSArray *) getUnsentStatements:(int)limit
{
    NSLog(@"getting statement list");
    _managedObjectContext = [TCOfflineDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalStatement"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:limit];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postedDate = nil"];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"createDate"
                                        ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchResults = [_managedObjectContext
                             executeFetchRequest:fetchRequest
                             error:&error];
    NSLog(@"error - %@", error);
    //NSLog(@"getUnsentStatements - %@",fetchResults);
    return fetchResults;
}
//
//- (void) sendUnsentStatements:(int)limit withCompletionBlock:(void(^)())completionBlock withErrorBlock:(void(^)(NSError *))errorBlock
//{
//    NSArray *unsentStatements = [self getUnsentStatements:500];
//    NSLog(@"sending %li statements to server", (unsigned long)unsentStatements.count);
//    
//    for (LocalStatements *localStatement in unsentStatements) {
//        //NSLog(@"localStatement %@", localStatement);
//        //NSLog(@"parsed statement %@", [localStatement statementJson]);
//        TCStatement *statementToSend = [[TCStatement alloc] initWithJSON:[localStatement statementJson]];
//        
//        NSLog(@"sending statement to server");
//        [self sendStatementToServer:statementToSend withCompletionBlock:^{
//            NSLog(@"statement posted... deleting");
//            [statementQueue markStatementPosted:statementToSend];
//            
//        }withErrorBlock:^(NSError *error)
//         {
//             NSLog(@"error sendAllStatementsToServerWithCompletionBlock : %@",[error userInfo]);
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 errorBlock(error);
//             });
//         }];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        completionBlock();
//    });
//}

- (void) markStatementPosted:(TCStatement *)statementPosted
{
    NSLog(@"deleting statementId %@", statementPosted.statementId);
    //update statement row with postedDate
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalStatement" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"statementId = %@", statementPosted.statementId];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"error marking statement posted : %@", [error userInfo]);
    }

    LocalStatements *statementToDelete = [fetchedObjects objectAtIndex:0];
    [_managedObjectContext deleteObject:statementToDelete];
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end
