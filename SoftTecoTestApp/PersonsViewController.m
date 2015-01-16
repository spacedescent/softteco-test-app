//
//  ViewController.m
//  SoftTecoTestApp
//
//  Created by Alexander Akimov on 1/13/15.
//  Copyright (c) 2015 Alexander Akimov. All rights reserved.
//

#import "PersonsViewController.h"
#import "Person+AddressBook.h"
#import "PersonInfoCell.h"
#import "PersonFBDetailsViewController.h"
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>

#define COLLECTION_VIEW_MINIMUM_SPACES 60 // left space + right space + middle space to borders
#define COLLECTION_VIEW_CELL_INSET_LEFT 20
#define COLLECTION_VIEW_CELL_INSET_TOP 20
#define COLLECTION_VIEW_CELL_INSET_RIGHT 20
#define COLLECTION_VIEW_CELL_INSET_BOTTOM 20


@interface PersonsViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@end

@implementation PersonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register observer to receive notifications on Address Book data loading completion
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDataLoaded:) name:@"AddressBookDataLoadedNotification" object:nil];
    NSLog(@"=== AddressBookDataLoadedNotification - observer added ===");
    
    // Forcing FetchedResultsController to update its data
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    // Creating FetchiedResultsController on given MOC to use with our Collection View
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Person"
                                                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
}

- (void)addressBookDataLoaded:(NSNotification *)notification
{
    NSLog(@"=== AddressBookDataLoadedNotification received ===");
    
    // Forcing FetchedResultsController to update its data
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    // Update Collection view (we are getting this notification not from the main queue)
    //[self.collectionView setContentOffset:CGPointZero animated:NO];
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show FB Details"])
    {
        if([segue.destinationViewController isKindOfClass:[PersonFBDetailsViewController class]])
        {
            PersonFBDetailsViewController *dvc = (PersonFBDetailsViewController *)segue.destinationViewController;
            
            // Using sender argument to pass Person to prepareForSegue
            Person *person = (Person *)sender;
            dvc.person = person;
        }
            
    }
}

#pragma mark - UICollectionView Datasource

// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
     if ([[self.fetchedResultsController sections] count] > 0) {
         id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
         
         // NSLog(@"%lu", (unsigned long)[sectionInfo numberOfObjects]);
         return [sectionInfo numberOfObjects];
     } else
     return 0;
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PersonInfoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Person Cell" forIndexPath:indexPath];
    
    Person *person = (Person *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.person = person;
   
    return cell;
}

// 4
/*
 - (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
     return [[UICollectionReusableView alloc] init];
 }
*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (FBSession.activeSession.isOpen)
    {
        PersonInfoCell *cell = (PersonInfoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        // Passing Person data in sender argument to prepareForSegue
        [self performSegueWithIdentifier:@"Show FB Details" sender:cell.person];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Warning")
                                                        message:NSLocalizedString(@"Login Facebook to watch user details!", @"Not logged")
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width = (self.collectionView.frame.size.width - COLLECTION_VIEW_MINIMUM_SPACES) / 2;
    CGSize retval = CGSizeMake(width, width);
    return retval;
}

// 2
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(COLLECTION_VIEW_CELL_INSET_LEFT,
                            COLLECTION_VIEW_CELL_INSET_TOP,
                            COLLECTION_VIEW_CELL_INSET_RIGHT,
                            COLLECTION_VIEW_CELL_INSET_BOTTOM);
}


@end
