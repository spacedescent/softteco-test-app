//
//  Person.h
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/26/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * facebookName;
@property (nonatomic, retain) NSData * facebookPicture;

@end