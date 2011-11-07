//
//  KeychainWrapper.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>

@interface KeychainWrapper : NSObject

// Generic exposed method to search the keychain for a given value.  Limit one result per search.
+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier;

// Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;

// Simple method to compare a passed in Hash value with what is stored in the keychain.
// Optionally, we could adjust this method to take in the keychain key to look up the value
+ (BOOL)compareKeychainValueForMatchingPIN:(NSUInteger)pinHash;

// Default initializer to store a value in the keychain.  
// Associated properties are handled for you (setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

// Updates a value in the keychain.  If you try to set the value with createKeychainValue: and it already exists
// this method is called instead to update the value in place.
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

// Delete a value in the keychain
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

// Generates an SHA1 (much more secure than MD5) Hash
+ (NSString *)securedSHA1DigestHashForPIN:(NSUInteger)pinHash;
+ (NSString*)computeSHA1DigestForString:(NSString*)input;

@end
