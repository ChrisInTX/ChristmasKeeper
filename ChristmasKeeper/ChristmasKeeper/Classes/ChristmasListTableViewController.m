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

#pragma mark - View lifecycle
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddChristmasPresent"]) {
        UINavigationController *navigationController = segue.destinationViewController;
		AddChristmasItemViewController *playerDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
		playerDetailsViewController.delegate = self;
    } else  if ([[segue identifier] isEqualToString:@"ChristmasDetailsSegue"]) {
        //UINavigationController *navigationController = segue.destinationViewController;
		ChristmasDetailsTableViewController *playerDetailsViewController = segue.destinationViewController; //= [[navigationController viewControllers] objectAtIndex:0];
		playerDetailsViewController.textHolder = [[self.christmasGifts objectAtIndex:self.selectedRow] objectForKey:@"text"];
		playerDetailsViewController.presentImageName = [[self.christmasGifts objectAtIndex:self.selectedRow] objectForKey:@"imageName"];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.christmasGifts = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Hi Chris", @"text",@"latest_photo.jpg", @"imageName", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Hi Rich", @"text",@"latest_photo.jpg", @"imageName", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Hi Laura", @"text",@"latest_photo.jpg", @"imageName", nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Hi Jack", @"text", @"latest_photo.jpg", @"imageName",nil], nil];
}
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.christmasGifts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    ChristmasListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChristmasListCell"];
    cell.textView.text = [[self.christmasGifts objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *newImage = [UIImage imageWithContentsOfFile:imagePath];
        [cell.thumbnail setImage:newImage];  
    }
    // Configure the cell...
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
    return indexPath;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.christmasGifts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //[self.tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)addChristmasItemToList:(NSDictionary *)item {
    [self.christmasGifts addObject:item];
    
    [self.tableView reloadData];
}

@end
