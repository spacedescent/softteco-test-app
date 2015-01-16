//
//  PersonInfoCell.h
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/13/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;

@interface PersonInfoCell : UICollectionViewCell
@property (nonatomic, strong) Person *person;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;

@end

