//
//  ChristmasConstants.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PIN_SAVED @"hasSavedPIN"
#define USERNAME @"username"
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

@interface ChristmasConstants : NSObject

@end
