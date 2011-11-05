//
//  ChristmasConstants.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>

// Used for saving to NSUserDefaults that a PIN has been set and as the unique identifier for the Keychain
#define PIN_SAVED @"hasSavedPIN"

// Used for saving the users name to NSUserDefaults
#define USERNAME @"username"

// Used to specify the Application used in Keychain accessing
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

@interface ChristmasConstants : NSObject

@end
