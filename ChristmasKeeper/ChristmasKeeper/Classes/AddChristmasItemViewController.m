//
//  AddChristmasItemViewController.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 11/1/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "AddChristmasItemViewController.h"
#import <ImageIO/ImageIO.h>

@implementation AddChristmasItemViewController
@synthesize delegate, presentText, presentImage, imagePicker, presentImageFileName;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)presentPickerForPhoto {
    // Create image picker controller
    
    // Set source to the camera
    self.imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Delegate is self
    self.imagePicker.delegate = self;
    
    // Allow editing of image ?
    self.imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentModalViewController:self.imagePicker animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.presentImage setImage:image];
    
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error = nil;
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    NSString *fileName = [NSString stringWithFormat:@"photo_%i.jpeg", [dirContents count]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    self.presentImageFileName = [NSString stringWithFormat:fileName];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];   
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *webData = UIImageJPEGRepresentation(editedImage, 1.0);
        [webData writeToFile:imagePath atomically:YES];
    }

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.imagePicker = [[UIImagePickerController alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self presentPickerForPhoto];
            break;
        default:
            break;
    }
}

-(IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)done:(id)sender {
    // If the user just presses "Done" without setting an image, this would be blank
    if (!self.presentImageFileName) {
        self.presentImageFileName = [NSString stringWithFormat:@"default_image.jpeg"];
    }
    
    if (self.delegate && [(id)self.delegate respondsToSelector:@selector(addChristmasItemToList:)]) {
        NSDictionary *newPresent = [NSDictionary dictionaryWithObjectsAndKeys:self.presentText.text, @"text", self.presentImageFileName, @"imageName", nil];
        [self.delegate addChristmasItemToList:newPresent];
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
