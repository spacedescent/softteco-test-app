//
//  PersonInfoCell.m
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/13/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import "PersonInfoCell.h"
#import "Person.h"
#import <UIKit/UIKit.h>

#define ALERT_NO_EMAIL NSLocalizedString(@"[ No email provided ]", @"No email")

@implementation PersonInfoCell

-(void) setPerson:(Person *)person {
    
    if(_person != person) {
        _person = person;
    }

    self.emailLabel.text = _person.email.length ? _person.email : ALERT_NO_EMAIL;
    self.fullNameLabel.text = _person.fullName;
    
    self.imageView.image = (_person.imageData.length) ? [UIImage imageWithData:_person.imageData] :
                                                        [UIImage imageNamed:@"user_avatar_empty"];
}

@end
