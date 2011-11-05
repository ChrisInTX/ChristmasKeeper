//
//  AddChristmasItemViewController.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 11/1/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChristmasItems;
@protocol AddChristmasItemDelegate;

@interface AddChristmasItemViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextView *presentText;
@property (nonatomic, strong) IBOutlet UIImageView *presentImage;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSString *presentImageFileName;
@property (nonatomic, weak) id<AddChristmasItemDelegate> delegate;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;

@end

@protocol AddChristmasItemDelegate <NSObject>
-(void)addChristmasItemToList:(NSDictionary *)item;
@end