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
        UITextField *text = [alert textFieldAtIndex:0];
        text.delegate = self;
        text.autocapitalizationType = UITextAutocapitalizationTypeWords;
        text.tag = kTextFieldPIN;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup Credentials" message:@"Secure your Christmas list!"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        alert.tag = kAlertTypeSetup;
        UITextField *text = [alert textFieldAtIndex:0];
        text.autocapitalizationType = UITextAutocapitalizationTypeWords;
        text.placeholder = @"Name"; // Replace the standard placeholder text with something more applicable
        text.delegate = self;
        text.tag = kTextFieldName;
        UITextField *text1 = [alert textFieldAtIndex:1]; // Capture the Password text field since there are 2 fields
        text1.delegate = self;
        text1.tag = kTextFieldPassword;
        [alert show];
    }
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    pinValidated = NO;
    credentialsValidated = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentAlertViewForPassword];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldPIN:
            NSLog(@"User entered PIN to validate");
            if ([textField.text length] > 0) {
                NSUInteger fieldHash = [textField.text hash];
                NSString *fieldString = [NSString stringWithFormat:@"%i", fieldHash];
                NSLog(@"** Password Hash - %@", fieldString);
                NSString *savedString = [KeychainWrapper keychainStringFromMatchingIdentifier:PIN_SAVED];
                if ([fieldString isEqual:savedString]) {
                    NSLog(@"** User Authenticated!!");
                    pinValidated = YES;
                } else {
                    NSLog(@"** Wrong Password :(");
                    pinValidated = NO;
                }
            }
            break;
        case kTextFieldName:
            NSLog(@"User entered name");
            if ([textField.text length] > 0) {
                [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case kTextFieldPassword:
            NSLog(@"User entered PIN");
            if ([textField.text length] > 0) {
                NSUInteger fieldHash = [textField.text hash];
                NSString *fieldString = [NSString stringWithFormat:@"%i", fieldHash];
                NSLog(@"** Password Hash - %@", fieldString);
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

- (BOOL)credentialsValidated {
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    BOOL pin =    [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if (name && pin) {
        credentialsValidated = YES;
        return YES;
    } else {
        credentialsValidated = NO;
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTypePIN) {
        if (buttonIndex == 1 && pinValidated) { // "Done" button
            [self performSegueWithIdentifier:@"ChristmasTableSegue" sender:self];
            pinValidated = NO;
        } else {
            [self presentAlertViewForPassword];
        }
    } else if (alertView.tag == kAlertTypeSetup) {
        if (buttonIndex == 1 && [self credentialsValidated]) {
            [self performSegueWithIdentifier:@"ChristmasTableSegue" sender:self];
            credentialsValidated = NO;
        } else {
            [self presentAlertViewForPassword];
        }
    }
}

@end
