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

@implementation PersonInfoCell

-(void) setPerson:(Person *)person {
    
    if(_person != person) {
        _person = person;
    }

    self.emailLabel.text = _person.email.length ? _person.email : NSLocalizedString(@"[ No email provided ]", @"No email");
    self.fullNameLabel.text = _person.fullName;
    
    self.imageView.image = (_person.imageData.length) ? [UIImage imageWithData:_person.imageData] :
                                                        [UIImage imageNamed:@"user_avatar_empty"];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Drawing rounded rect border around the cell
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4.0f];
    [[UIColor blackColor] setStroke];
    [path stroke];
}

@end
