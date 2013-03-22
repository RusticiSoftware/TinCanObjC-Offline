//
//  TCStatementCollection.m
//  RSTCAPI
//
//  Created by Brian Rogers on 3/7/13.
//  Copyright (c) 2013 Brian Rogers. All rights reserved.
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

- (void) addStatement:(TCStatement *)statement
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
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
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

- (void) markStatementPosted:(TCStatement *)statementPosted
{
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

    LocalStatements *statementToUpdate = [fetchedObjects objectAtIndex:0];
    [statementToUpdate setPostedDate:[NSDate date]];
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end
