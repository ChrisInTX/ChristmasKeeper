//
//  KeychainWrapper.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "KeychainWrapper.h"
#import "ChristmasConstants.h"

@implementation KeychainWrapper
// *** NOTE *** This class is ARC compliant - any references to CF classes must be paired with a "__bridge" statement to 
// cast between Objective-C and Core Foundation Classes.  WWDC 2011 Video "Introduction to Automatic Reference Counting" explains this
// *** END NOTE ***
+ (NSMutableDictionary *)setupSearchDirectoryForIdentifier:(NSString *)identifier {
    
    // Setup dictionary to access keychain
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
    // Specify we are using a Password (vs Certificate, Internet Password, etc)
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Uniquely identify this keychain accesser
    [searchDictionary setObject:APP_NAME forKey:(__bridge id)kSecAttrService];
	
    // Uniquely identify the account who will be accessing the keychain
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
	
    return searchDictionary; 
}

+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier {
   
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    // Limit search results to one
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	
    // Specify we want NSData/CFData returned
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
    // Search
    NSData *result = nil;   
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    if (status == noErr) {
        result = (__bridge_transfer NSData *)foundDict;
    } else {
        result = nil;
    }
    
    return result;
}

+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier {
   NSData *valueData = [self searchKeychainCopyMatchingIdentifier:identifier];
    if (valueData) {
        NSString *value = [[NSString alloc] initWithData:valueData
                                                   encoding:NSUTF8StringEncoding];
        return value;
    } else {
        return nil;
    }
}

+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
   
    NSMutableDictionary *dictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:valueData forKey:(__bridge id)kSecValueData];
   
    // Protect the keychain entry so its only valid when the device is unlocked
    [dictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];

    // Add
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
	
    // If the Addition was successful, return.  Otherwise, attempt to update existing key or quit (return NO)
    if (status == errSecSuccess) {
        return YES;
    } else if (status == errSecDuplicateItem){
        return [self updateKeychainValue:value forIdentifier:identifier];
    } else {
        return NO;
    }
}

+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
    
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:valueData forKey:(__bridge id)kSecValueData];
	
    // Update
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
	
    if (status == errSecSuccess) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    CFDictionaryRef dictionary = (__bridge CFDictionaryRef)searchDictionary;
    
    //Delete
    SecItemDelete(dictionary);
}


+ (BOOL)compareKeychainValueForMatchingPIN:(NSUInteger)pinHash {
    
    if ([[self keychainStringFromMatchingIdentifier:PIN_SAVED] isEqualToString:[self securedSHA1DigestHashForPIN:pinHash]]) {
        return YES;
    } else {
        return NO;
    }    
}

// This is where most of the magic happens (the rest of it happens in computeSHA1DigestForString: method below)
// Here we are passing in the Hash of the PIN that the user entered so that we can avoid manually handling the PIN itself
// Then we are extracting the user name that the user supplied during setup so that we can add another unique element to the hash
// From there, we mash the user name, the passed in PIN Hash, and the secret key (From ChristmasConstants.h) together to create 
// one long, unique string.
// From here, we send that entire Hash mashup into the SHA1 method below to create a "Digital Digest" which is considered
// a one way encryption algorithm.  One way meaning that it can never be reverse-engineered, only brute-force attacked
// The algorthim we are using is 'Hash = SHA1(Name + Salt + (Hash(PIN)))'.  This is called "Digest Authentication"
+ (NSString *)securedSHA1DigestHashForPIN:(NSUInteger)pinHash {
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *computedHashString = [NSString stringWithFormat:@"%@%i%@", name, pinHash, SALT_HASH];
    NSString *finalHash = [self computeSHA1DigestForString:computedHashString];
    NSLog(@"** Computed hash: %@ for SHA1 Digest: %@", computedHashString, finalHash);
    return finalHash;
}

// This is where the rest of the magic happens
// Here we are taking in our string hash, placing that inside of a C Char Array, then parsing it through the SHA1 encryption method
+ (NSString*)computeSHA1DigestForString:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    // This is an iOS5-specific method
    // Takes in the data, how much data, and then output format which in this case is an int array
    CC_SHA1(data.bytes, data.length, digest);
    
    // Setup our Objective-C output 
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA1 results (stored inside of digest[])
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
