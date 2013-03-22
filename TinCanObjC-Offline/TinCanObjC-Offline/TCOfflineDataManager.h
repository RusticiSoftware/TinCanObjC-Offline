//
//  TCDataManager.h
//  RSTCAPI
//
//  Created by Brian Rogers on 1/29/13.
//  Copyright (c) 2013 Brian Rogers. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface TCOfflineDataManager : NSObject {
    
    NSString *storePath;
    NSURL *storeURL;
    
}

@property (nonatomic, retain) NSString *storePath;
@property (nonatomic, retain) NSURL *storeURL;

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (TCOfflineDataManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;

@end