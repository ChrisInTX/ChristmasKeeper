//
//  ChristmasDetailsTableViewController.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/29/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChristmasDetailsTableViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UITextView *presentText;
@property (nonatomic, strong) IBOutlet UIImageView *presentImage;
@property (nonatomic, strong) NSString *textHolder;
@property (nonatomic, strong) NSString *presentImageName;
- (IBAction)tweetButtonTapped:(id)sender;
@end
