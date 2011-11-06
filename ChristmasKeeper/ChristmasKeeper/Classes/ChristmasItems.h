//
//  ChristmasItems.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 11/6/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChristmasItems : NSObject
@property (nonatomic, strong) NSMutableArray *christmasList;

// Default initializer
- (id)initWithJSONFromFile:(NSString *)jsonFileName;

// Exposed method to load the data directly into the 'christmasList' mutable array
- (NSMutableArray *)dataFromJSONFile:(NSString *)jsonFileName;

// Helper method to ensure that we have a default image for users who dont specify a new picture 
- (void)writeDefaultImageToDocuments;

// Writes JSON file to disk, using Data Protection API
- (void)saveChristmasGifts;

// Should someone delete a present, we can remove it directly, then save the new list to disk (saveChristmasGifts)
- (void)removeGiftAtIndexPath:(NSIndexPath *)indexPath;

// Should someone add a present, we can add it directly, then save the new list to disk (saveChristmasGifts)
- (void)addPresentToChristmasList:(NSDictionary *)newItem;

// Accessor method to retrieve the saved image for a given present
- (UIImage *)imageForPresentAtIndex:(NSIndexPath *)indexPath;

// Accessor method to retrieve the saved text for a given present
- (NSString *)textForPresentAtIndex:(NSIndexPath *)indexPath;

// Accessor method to retrieve the saved image name for a given present
- (NSString *)imageNameForPresentAtIndex:(NSIndexPath *)indexPath;

@end
