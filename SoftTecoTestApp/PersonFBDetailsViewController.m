//
//  PersonFBDetailsViewController.m
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/15/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import "PersonFBDetailsViewController.h"
#import "Person.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PersonFBDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *personFBNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PersonFBDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.person.fullName stringByAppendingString:NSLocalizedString(@" FB info", @" FB info")];
    
    self.personFBNameLabel.text = self.person.fullName;
    
    if (FBSession.activeSession.isOpen) {
        __block NSString *userID;
        __block NSString *userName;
        
        NSString *requestStr = [NSString stringWithFormat:@"search?q=%@+%@&type=user&limit=1", self.person.firstName, self.person.lastName];
        // Make appropriate encoding for russian names
        requestStr = [requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Fetching Facebook data for User ID and Name
        
        [[FBRequest requestForGraphPath:requestStr] startWithCompletionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error) {
            if(error) {
                NSLog(@"Error: %@", error);
                return;
            }
            else {
                NSDictionary *resultDic = (NSDictionary<FBGraphUser> *)result;

                userID = [((NSArray *)[resultDic valueForKeyPath:@"data.id"]) firstObject];
                userName = [((NSArray *)[resultDic valueForKeyPath:@"data.name"]) firstObject];
                
                if(!userID || !userName) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        self.personFBNameLabel.text = NSLocalizedString(@"[ User not found on Facebook ]", @"User not found on Facebook");
                    });
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    self.personFBNameLabel.text = userName;
                });
                
                // Fetching Facebook data for User profile picture
                
                NSString *urlText = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userID];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlText]];
                UIImage *profilePic = [UIImage imageWithData:imageData];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    self.avatarImageView.image = profilePic;
                    [self.activityIndicator stopAnimating];
                });
            }
        }];
    }
}

@end
