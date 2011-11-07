//
//  ChristmasDetailsTableViewController.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/29/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "ChristmasDetailsTableViewController.h"
#import <Twitter/Twitter.h>

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

- (IBAction)tweetButtonTapped:(id)sender { 
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:self.presentText.text];
        [tweetSheet addImage:self.presentImage.image];
        [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Tweeting is unavailable right now, check your internet connection and that you have at least one Twitter account setup" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
@end
