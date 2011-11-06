//
//  ChristmasListTableViewController.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/29/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "ChristmasListTableViewController.h"
#import "ChristmasListTableViewCell.h"
#import "ChristmasDetailsTableViewController.h"

@implementation ChristmasListTableViewController
@synthesize christmasGifts, selectedRow;

#pragma mark - UIStoryBoardSegue Method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddChristmasPresent"]) {
        // Set the delegate for the modal thats about to present
        UINavigationController *navigationController = segue.destinationViewController;
		AddChristmasItemViewController *playerDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
		playerDetailsViewController.delegate = self;
    } else  if ([[segue identifier] isEqualToString:@"ChristmasDetailsSegue"]) {
        // Pass-forward the details about the present
		ChristmasDetailsTableViewController *playerDetailsViewController = segue.destinationViewController;
		playerDetailsViewController.textHolder = [self.christmasGifts textForPresentAtIndex:self.selectedRow];
		playerDetailsViewController.presentImageName = [self.christmasGifts imageNameForPresentAtIndex:self.selectedRow];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.christmasGifts = [[ChristmasItems alloc] initWithJSONFromFile:@"christmasItems.json"];

    // Register for the Data Protection Notifications (Lock and Unlock).  
    // ** NOTE ** These are only enforced when a user has their device Passcode Protected!
    // Data Protection is not available in the Simulator
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceWillLock) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceWillUnLock) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
}

// We still must manually remove ourselves from observing
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data Protection Testing Methods

// This method will get called when the device is locked, but checkKey will not.  It is queued until the file becomes available again.
- (void)deviceWillLock {
    NSLog(@"** Device is will become locked");
    [self performSelector:@selector(checkFile) withObject:nil afterDelay:10];
}

- (void)deviceWillUnLock {
    NSLog(@"** Device is unlocked");
    [self performSelector:@selector(checkFile) withObject:nil afterDelay:10];
}

- (void)checkFile {
    NSLog(@"** Validate Data Protection: checkFile");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"christmasItems.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSData *responseData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil]; 
        NSLog(@"** FILE %@", json);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.christmasGifts.christmasList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    ChristmasListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChristmasListCell"];
    cell.textView.text = [[self.christmasGifts.christmasList objectAtIndex:indexPath.row] objectForKey:@"text"];
    [cell.thumbnail setImage:[self.christmasGifts imageForPresentAtIndex:indexPath]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath; // Save the selected indexPath so that the prepareForSegue method can access the right data
    return indexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.christmasGifts removeGiftAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }   
}

#pragma mark - AddChristmasItemViewController Delegate Callback

-(void)addChristmasItemToList:(NSDictionary *)item {
    [self.christmasGifts addPresentToChristmasList:item];
    [self.tableView reloadData];
}

@end
