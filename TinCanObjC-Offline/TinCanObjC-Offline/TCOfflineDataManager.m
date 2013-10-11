//
//  TCDataManager.m
//  RSTCAPI
//
//  Created by Brian Rogers on 1/29/13.
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

#import "TCOfflineDataManager.h"

NSString * const TCOfflineDataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const TCOfflineDataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface TCOfflineDataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation TCOfflineDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;
@synthesize storePath = _storePath;
@synthesize storeURL = _storeURL;

NSString * const kTCOfflineDataManagerBundleName = @"TinCanObjC-OfflineResources";
NSString * const kTCOfflineDataManagerModelName = @"TCLocalStorage";
NSString * const kTCOfflineDataManagerSQLiteName = @"TinCanObjC-LocalStorage.sqlite";

+ (TCOfflineDataManager*)sharedInstance {
	static dispatch_once_t pred;
	static TCOfflineDataManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (void)dealloc {
	[self save];
}

- (NSManagedObjectModel*)objectModel {
	if (_objectModel)
		return _objectModel;
    
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//	if (kDataManagerBundleName) {
//		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDataManagerBundleName ofType:@"bundle"];
//		bundle = [NSBundle bundleWithPath:bundlePath];
//	}
	NSString* mainBundlePath = [bundle resourcePath];
    NSLog(@"mainBundlePath %@", mainBundlePath);
    NSString* frameworkBundlePath;
    
    if([[mainBundlePath lastPathComponent] isEqualToString:@"TinCanObjC-OfflineTests.octest"])
    {
        frameworkBundlePath = mainBundlePath;
    }else{
        frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle",kTCOfflineDataManagerBundleName]];
    }
   
    NSLog(@"frameworkBundlePath %@", frameworkBundlePath);    
    NSString *path = [[NSBundle bundleWithPath:frameworkBundlePath] pathForResource:@"TCLocalStorage" ofType:@"momd"];
    
    NSLog(@"modelPath %@", path);
    
    NSURL *momURL = [NSURL fileURLWithPath:path];

    
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
	return _objectModel;
    
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
	// Get the paths to the SQLite file
	_storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kTCOfflineDataManagerSQLiteName];
    
    NSLog(@"storePath : %@", _storePath);
    
	_storeURL = [NSURL fileURLWithPath:_storePath];
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
    
    
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:_storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
	if (_mainObjectContext)
		return _mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}
    
	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _mainObjectContext;
}

- (BOOL)save {
	if (![self.mainObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:TCOfflineDataManagerDidSaveFailedNotification
                                                            object:error];
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:TCOfflineDataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString*)sharedDocumentsPath {
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return ctx;
}

@end