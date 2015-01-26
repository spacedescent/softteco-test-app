//
//  PersistenceManager.h
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/26/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol PersistenceManagerABErrorDelegate <NSObject>
@required
- (void) AddressBookErrorOccured:(NSString *)errorMessage;
@end

@interface PersistenceManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (PersistenceManager *) sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)loadContactsFromAddressBook:(id<PersistenceManagerABErrorDelegate>)delegateView;

@end
