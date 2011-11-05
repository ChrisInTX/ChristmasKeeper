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
		ChristmasDetailsTableViewController *playerDetailsViewController = segue.destinationViewController;
		playerDetailsViewController.textHolder = [[self.christmasGifts objectAtIndex:self.selectedRow] objectForKey:@"text"];
		playerDetailsViewController.presentImageName = [[self.christmasGifts objectAtIndex:self.selectedRow] objectForKey:@"imageName"];
    }
}

- (void)writeChristmasGiftsToDisk {
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:self.christmasGifts forKey:@"gifts"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary 
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"christmasItems.json"];
    [jsonData writeToFile:jsonPath options:NSDataWritingFileProtectionComplete error:&error];
    [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey] ofItemAtPath:jsonPath error:&error];
}

- (NSMutableArray *)dataFromJSONFile {
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"christmasItems.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSError* error = nil;
        NSData *responseData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];        
        return [[NSMutableArray alloc] initWithArray:[json objectForKey:@"gifts"]];
    }

    return [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Thank Chris Lowe for an awesome tutorial on Basic iOS Security!", @"text",@"noImage", @"imageName", nil], nil];
}

- (void)writeDefaultImageToDocuments {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"default_image.jpeg"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *editedImage = [UIImage imageNamed:@"images.jpeg"];
        NSData *webData = UIImageJPEGRepresentation(editedImage, 1.0);
        [webData writeToFile:imagePath atomically:YES];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.christmasGifts = [self dataFromJSONFile];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceWillLock)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceWillUnLock)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable 
                                               object:nil];
    [self writeDefaultImageToDocuments];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// This method will get called when the device is locked, but checkKey will not.  It is queued until the file becomes available again.
- (void)deviceWillLock {
    NSLog(@"device is about to be locked");
    [self performSelector:@selector(checkKey) withObject:nil afterDelay:10];
}

- (void)deviceWillUnLock {
    NSLog(@"device is about to be unlocked");
    [self performSelector:@selector(checkKey) withObject:nil afterDelay:10];
}

- (void)checkKey {
    NSLog(@"checkKey");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"christmasItems.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSData *responseData = [NSData dataWithContentsOfFile:jsonPath];
        NSError *error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]; 
        NSLog(@"** FILE %@", json);
    }

}

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
    NSString *imageKey = [[self.christmasGifts objectAtIndex:indexPath.row] objectForKey:@"imageName"];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *newImage = [UIImage imageWithContentsOfFile:imagePath];
        [cell.thumbnail setImage:newImage];  
    } else {
        UIImage *newImage = [UIImage imageNamed:@"images.jpeg"];
        [cell.thumbnail setImage:newImage];
    }
    
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

- (void)deleteImageWithName:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath] && (![@"default_image.jpeg" isEqualToString:imageName])) {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deleteImageWithName:[[self.christmasGifts objectAtIndex:indexPath.row] objectForKey:@"imageName"]];
        [self.christmasGifts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self writeChristmasGiftsToDisk];
    }   
}

-(void)addChristmasItemToList:(NSDictionary *)item {
    [self.christmasGifts addObject:item];
    [self.tableView reloadData];
    [self writeChristmasGiftsToDisk];
}

@end
