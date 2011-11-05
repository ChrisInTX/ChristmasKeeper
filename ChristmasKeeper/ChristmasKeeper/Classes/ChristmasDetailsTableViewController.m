//
//  ChristmasDetailsTableViewController.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/29/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "ChristmasDetailsTableViewController.h"


@implementation ChristmasDetailsTableViewController
@synthesize presentImage,presentText,textHolder,presentImageName;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.presentText = nil;
    self.presentImage = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.presentText.text = self.textHolder;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:self.presentImageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *newImage = [UIImage imageWithContentsOfFile:imagePath];
        [self.presentImage setImage:newImage];  
    }
    
    [super viewWillAppear:animated];
}

@end
