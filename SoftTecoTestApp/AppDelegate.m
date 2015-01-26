//
//  AppDelegate.m
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/13/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Person+AddressBook.h"
#import "PersistenceManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

-(void)loadContactsFromAddressBook {
    CFErrorRef *error = NULL;	
    ABAddressBookRef addressBook = NULL;
    
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted: { // 1
            NSLog(@"Denied");
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"Sorry")
                                        message:NSLocalizedString(@"Address Book access denied", @"Address Book access denied")
                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
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
                    CFRelease(addressBook);
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"Sorry")
                                                message:NSLocalizedString(@"Address Book access denied", @"Address Book access denied")
                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
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
  
        if(ABMultiValueGetCount(emails))
        {
            // Getting the 1st email
            CFTypeRef cfEmail = ABMultiValueCopyValueAtIndex(emails, 0);
            email = (__bridge_transfer NSString *)cfEmail;
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // Loading data from address book and storing in Core Data
    [self loadContactsFromAddressBook];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[PersistenceManager sharedInstance] saveContext];
}

#pragma mark - Facebook SDK methods

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
