//
//  Person+AddressBook.m
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/13/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import "Person+AddressBook.h"

@implementation Person (AddressBook)
+(Person *)personWithFirstName:(NSString *)firstName
                 lastName:(NSString *)lastName
                    email:(NSString *)email
            withImageData:(NSData *)imageData
                inContext:(NSManagedObjectContext *)context
{
    Person *person = nil;
    
    
    // Checking if such a person already exists in Core Data storage
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"fullName = %@", fullName];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        person = [matches firstObject];
    } else {
        // If person not exists - creating a new one
        person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                              inManagedObjectContext:context];
        person.fullName = fullName;
        person.firstName = firstName;
        person.lastName = lastName;
        person.email = email;
        person.imageData = imageData;
    }
    
    return person;
}

@end
