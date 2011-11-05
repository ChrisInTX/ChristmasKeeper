//
//  ChristmasListTableViewCell.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 11/1/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <UIKit/UIKit.h>

// This table cell was created to easily manage the Table list of Christmas Presents
@interface ChristmasListTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UILabel *textView;
@end
