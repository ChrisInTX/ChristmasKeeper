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
        // Set the delegate for the modal thats about to present
        UINavigationController *navigationController = segue.destinationViewController;
		AddChristmasItemViewController *playerDetailsViewController = [[navigationController viewControllers] objectAtIndex:0];
		playerDetailsViewController.delegate = self;
    } else  if ([[segue identifier] isEqualToString:@"ChristmasDetailsSegue"]) {
        // Pass-forward the details about the present
		ChristmasDetailsTableViewController *playerDetailsViewController = segue.destinationViewController;
		playerDetailsViewController.textHolder = [[self.christmasGifts objectAtIndex:self.selectedRow] objectForKey:@"text"];
		playerDetailsViewController.presentImageName = [[self.christmasGifts objectAtIndex:self.selectedRow] objectForKey:@"imageName"];
    }
}

// Helper method to save the JSON file
// Here we are Write Protecting the file, then we are setting the file itself to use File Protection (Data At Rest)
- (void)writeChristmasGiftsToDisk {
   
    NSError *error = nil;
    // We wrap our Gifts array inside of a Dictionary to follow the standard JSON format (you could keep it as an Array)
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:self.christmasGifts forKey:@"gifts"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary 
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"christmasItems.json"];
    [jsonData writeToFile:jsonPath options:NSDataWritingFileProtectionComplete error:&error];
    [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey] ofItemAtPath:jsonPath error:&error];
}

// Helper method to get the data from the JSON file
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

    // We have to have a default Cell :)
    return [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Thank Chris Lowe for an awesome tutorial on Basic iOS Security!", @"text",@"noImage", @"imageName", nil], nil];
}

// This method ensures that we always have an image available in case the user doesnt specify one
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
    [self writeDefaultImageToDocuments];

    // Register for the Data Protection Notifications (Lock and Unlock).  
    // ** NOTE ** These are only enforced when a user has their device Passcode Protected!
    // Data Protection is not available in the Simulator
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceWillLock)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceWillUnLock)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable 
                                               object:nil];
}

// We still must manually remove ourselves from observing
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    return [self.christmasGifts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    ChristmasListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChristmasListCell"];
    cell.textView.text = [[self.christmasGifts objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    //Admittedly not the most efficient way to set an image but thats not the point of the tutorial :)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageKey = [[self.christmasGifts objectAtIndex:indexPath.row] objectForKey:@"imageName"];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *newImage = [UIImage imageWithContentsOfFile:imagePath];
        [cell.thumbnail setImage:newImage];  
    } else { // If we dont have an "imageName" key then we use the default one
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
    self.selectedRow = indexPath.row; // Save the selected indexPath so that the prepareForSegue method can access the right data
    return indexPath;
}

- (void)deleteImageWithName:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    // Delete the file, but not the default image (we need that one!)
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
