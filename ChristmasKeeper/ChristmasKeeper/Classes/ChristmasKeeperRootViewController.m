//
//  ChristmasKeeperRootViewController.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/29/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "ChristmasKeeperRootViewController.h"
#import "ChristmasConstants.h"
#import "KeychainWrapper.h"

// Typedefs just to make it a little easier to read in code
typedef enum {
    kAlertTypePIN = 0,
    kAlertTypeSetup
} AlertTypes;

typedef enum {
    kTextFieldPIN = 1,
    kTextFieldName,
    kTextFieldPassword
} TextFieldTypes;

@implementation ChristmasKeeperRootViewController
@synthesize pinValidated;

- (void)presentAlertViewForPassword {
    
    // Retrieve whether the user has set a PIN or not (ie, 1st time use or 2nd+)
    BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
   
    // If user has set PIN, prompt for it, otherwise show Setup flow
    if (hasPin) {
        NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
        NSString *message = [NSString stringWithFormat:@"What is %@'s password?", user];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Password" message:message  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the password field
        alert.tag = kAlertTypePIN;
        UITextField *pinField = [alert textFieldAtIndex:0];
        pinField.delegate = self;
        pinField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        pinField.tag = kTextFieldPIN;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup Credentials" message:@"Secure your Christmas list!"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        alert.tag = kAlertTypeSetup;
        UITextField *nameField = [alert textFieldAtIndex:0];
        nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        nameField.placeholder = @"Name"; // Replace the standard placeholder text with something more applicable
        nameField.delegate = self;
        nameField.tag = kTextFieldName;
        UITextField *passwordField = [alert textFieldAtIndex:1]; // Capture the Password text field since there are 2 fields
        passwordField.delegate = self;
        passwordField.tag = kTextFieldPassword;
        [alert show];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pinValidated = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentAlertViewForPassword];
}

#pragma mark - Text Field + Alert View Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldPIN: // We go here if this is the 2nd+ time used (we've already set a PIN at Setup)
            NSLog(@"User entered PIN to validate");
            if ([textField.text length] > 0) {
                NSUInteger fieldHash = [textField.text hash]; // Get the hash of the entered PIN, minimize contact with the real password
                if ([KeychainWrapper compareKeychainValueForMatchingPIN:fieldHash]) { // Compare them
                    NSLog(@"** User Authenticated!!");
                    self.pinValidated = YES;
                } else {
                    NSLog(@"** Wrong Password :(");
                    self.pinValidated = NO;
                }
            }
            break;
        case kTextFieldName: // 1st part of the Setup flow
            NSLog(@"User entered name");
            if ([textField.text length] > 0) {
                [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case kTextFieldPassword: // 2nd half of the Setup flow
            NSLog(@"User entered PIN");
            if ([textField.text length] > 0) {
                NSUInteger fieldHash = [textField.text hash];
                NSString *fieldString = [KeychainWrapper securedSHA1DigestHashForPIN:fieldHash];
                NSLog(@"** Password Hash - %@", fieldString);
                // Save PIN hash to the keychain (NEVER store the direct PIN)
                if ([KeychainWrapper createKeychainValue:fieldString forIdentifier:PIN_SAVED]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
                    NSLog(@"** Key saved successfully to Keychain!!");
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }                
            }
            break;
        default:
            break;
    }
}

// Helper method to congregate the Name and PIN fields for validation 
- (BOOL)credentialsValidated {
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    BOOL pin =    [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if (name && pin) {
        return YES;
    } else {
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTypePIN) {
        if (buttonIndex == 1 && self.pinValidated) { // User selected "Done"
            [self performSegueWithIdentifier:@"ChristmasTableSegue" sender:self];
            self.pinValidated = NO;
        } else { // User selected "Cancel"
            [self presentAlertViewForPassword];
        }
    } else if (alertView.tag == kAlertTypeSetup) {
        if (buttonIndex == 1 && [self credentialsValidated]) { // User selected "Done"
            [self performSegueWithIdentifier:@"ChristmasTableSegue" sender:self];
        } else { // User selected "Cancel"
            [self presentAlertViewForPassword];
        }
    }
}

@end
