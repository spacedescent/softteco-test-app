//
//  Person+AddressBook.h
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/13/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import "Person.h"

@interface Person (AddressBook)

+(Person *)personWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
                  email:(NSString *)email
          withImageData:(NSData *)imageData
              inContext:(NSManagedObjectContext *)context;

@end
