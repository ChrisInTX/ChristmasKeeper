//
//  ChristmasItems.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 11/6/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "ChristmasItems.h"

@implementation ChristmasItems
@synthesize christmasList;

- (id)initWithJSONFromFile:(NSString *)jsonFileName {
    self = [super init];
    if (self) {
        self.christmasList = [self dataFromJSONFile:jsonFileName];
        [self writeDefaultImageToDocuments];
    }
    return self;
}

// Helper method to get the data from the JSON file
- (NSMutableArray *)dataFromJSONFile:(NSString *)jsonFileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:jsonFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSError* error = nil;
        NSData *responseData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];        
        return [[NSMutableArray alloc] initWithArray:[json objectForKey:@"gifts"]];
    }
    
    // We have to have a default Cell :)
    return [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Thank Chris Lowe for an awesome tutorial on Basic iOS Security! Maybe him on Twitter (@chrisintx)?", @"text",@"noImage", @"imageName", nil], nil];
}

// Helper method to save the JSON file
// Here we are Write Protecting the file, then we are setting the file itself to use File Protection (Data At Rest)
- (void)saveChristmasGifts {
    
    NSError *error = nil;
    // We wrap our Gifts array inside of a Dictionary to follow the standard JSON format (you could keep it as an Array)
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:self.christmasList forKey:@"gifts"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary 
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"christmasItems.json"];
    [jsonData writeToFile:jsonPath options:NSDataWritingFileProtectionComplete error:&error];
    [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey] ofItemAtPath:jsonPath error:&error];
}

// This method ensures that we always have an image available in case the user doesnt specify one
- (void)writeDefaultImageToDocuments {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"default_image.png"];
    // If the file does NOT exist, then save it
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *editedImage = [UIImage imageNamed:@"present.png"];
        NSData *webData = UIImagePNGRepresentation(editedImage);
        [webData writeToFile:imagePath atomically:YES];
    }
}

// Accessor method to retrieve the saved text for a given present
- (NSString *)textForPresentAtIndex:(NSIndexPath *)indexPath {
    return  [[self.christmasList objectAtIndex:indexPath.row] objectForKey:@"text"];
}

// Accessor method to retrieve the saved image name for a given present
- (NSString *)imageNameForPresentAtIndex:(NSIndexPath *)indexPath {
    return [[self.christmasList objectAtIndex:indexPath.row] objectForKey:@"imageName"];
}

- (UIImage *)imageForPresentAtIndex:(NSIndexPath *)indexPath {
    //Admittedly not the most efficient way to set an image but thats not the point of the tutorial :)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageKey = [[self.christmasList objectAtIndex:indexPath.row] objectForKey:@"imageName"];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageKey];
    UIImage *presentImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        presentImage = [UIImage imageWithContentsOfFile:imagePath];
    } else { // If we dont have an "imageName" key then we use the default one
        presentImage = [UIImage imageNamed:@"present.png"];
    }
    return presentImage;
}

- (void)deleteImageWithName:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    // Delete the file, but not the default image (we need that one!)
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath] && (![@"default_image.png" isEqualToString:imageName])) {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
}

- (void)addPresentToChristmasList:(NSDictionary *)newItem {
    [self.christmasList addObject:newItem];
    [self saveChristmasGifts];
}

- (void)removeGiftAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteImageWithName:[[self.christmasList objectAtIndex:indexPath.row] objectForKey:@"imageName"]];
    [self.christmasList removeObjectAtIndex:indexPath.row];
    [self saveChristmasGifts];
}

@end
