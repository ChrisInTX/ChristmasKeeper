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

@property (nonatomic, assign) id<AddChristmasItemDelegate> delegate;
-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;

@end

@protocol AddChristmasItemDelegate <NSObject>
-(void)addChristmasItemToList:(ChristmasItems *)item;
@end