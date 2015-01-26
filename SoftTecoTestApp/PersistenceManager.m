//
//  PersistenceManager.m
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/26/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//
#import <AddressBook/AddressBook.h>
#import "PersistenceManager.h"
#import "Person+AddressBook.h"

@implementation PersistenceManager

+ (PersistenceManager *) sharedInstance {
    static PersistenceManager *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PersistenceManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - AddressBook methods

-(void)loadContactsFromAddressBook:(id<PersistenceManagerABErrorDelegate>)delegateView {
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = NULL;
    
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted: { // 1
            NSLog(@"Denied");
            [delegateView AddressBookErrorOccured:NSLocalizedString(@"Address Book access denied", @"Address Book access denied")];
            break;
        }
            
        case kABAuthorizationStatusAuthorized: { // 2
            NSLog(@"Authorized");
            addressBook = ABAddressBookCreateWithOptions(NULL, error);
            [self loadContactsFromAddressBookByAddressBook:addressBook];
            CFRelease(addressBook);
            break;
        }
            
        case kABAuthorizationStatusNotDetermined: { // 3
            NSLog(@"Not determined");
            addressBook = ABAddressBookCreateWithOptions(NULL, error);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef err) {
                if (!granted) { // 4
                    NSLog(@"Just denied");
                    if (addressBook) {
                        CFRelease(addressBook);
                    }
                    [delegateView AddressBookErrorOccured:NSLocalizedString(@"Address Book access denied", @"Address Book access denied")];

                }
                else { // 5
                    NSLog(@"Just authorized");
                    [self loadContactsFromAddressBookByAddressBook:addressBook];
                    CFRelease(addressBook);
                }
            });
            break;
        }
    }
}

-(void)loadContactsFromAddressBookByAddressBook:(ABAddressBookRef)addressBook
{
    //    NSLog(@"=== Begin loading data === ");
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        CFTypeRef cfFirstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *firstName = (__bridge_transfer NSString *)cfFirstName;
        
        
        CFTypeRef cfLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)cfLastName;
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        NSString *email = nil;
        
        if(ABMultiValueGetCount(emails)) {
            // Getting the 1st email
            email = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, 0);
        }
        
        CFRelease(emails);
        
        CFDataRef cfImgData = ABPersonCopyImageData(person);
        NSData  *imgData = (__bridge_transfer NSData *)cfImgData; // Will be nil if no image in Address Book
        [Person personWithFirstName:firstName lastName:lastName email:email withImageData:imgData inContext:[PersistenceManager sharedInstance].managedObjectContext];
    }
    
    CFRelease(allPeople);
    
    if(numberOfPeople) {
        [[PersistenceManager sharedInstance] saveContext];
    }
    
    // Send a notification to view controller to update view
    //    NSLog(@"=== AddressBookDataLoadedNotification sent ===");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressBookDataLoadedNotification" object:nil];
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "none.SoftTecoTestApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SoftTecoTestApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SoftTecoTestApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
