//
//  ChristmasListTableViewController.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/29/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddChristmasItemViewController.h"

@interface ChristmasListTableViewController : UITableViewController <AddChristmasItemDelegate>
@property (nonatomic, strong) NSMutableArray *christmasGifts;
@property (nonatomic) NSUInteger selectedRow;
@end
