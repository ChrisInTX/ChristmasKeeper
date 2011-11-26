//
//  AddChristmasItemViewController.m
//  ChristmasKeeper
//
//  Created by Chris Lowe on 11/1/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import "AddChristmasItemViewController.h"

@implementation AddChristmasItemViewController
@synthesize delegate, presentText, presentImage, imagePicker, presentImageFileName;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)presentPickerForPhoto {
    
    // Set source to the Photo Library (so it works in Simulator and on non-camera devices)
    self.imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Set Delegate
    self.imagePicker.delegate = self;
    
    // Disable image editing
    self.imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentModalViewController:self.imagePicker animated:YES];
}

// Once the user has made a selection, the delegate call back comes here
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    // Access the original image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.presentImage setImage:image];
    
    // Capture the file name of the image
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error = nil;
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    NSString *fileName = [NSString stringWithFormat:@"photo_%i.png", [dirContents count]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    self.presentImageFileName = [NSString stringWithFormat:fileName];
    
    // Then save the image to the Documents directory
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];   
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *webData = UIImagePNGRepresentation(editedImage);
        [webData writeToFile:imagePath atomically:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Being proactive as the ImagePicker takes a while to load
     self.imagePicker = [[UIImagePickerController alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.presentText = nil;
    self.presentImage = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The user can tap the cell (where the present image is) to change the photo
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
        self.presentImageFileName = [NSString stringWithFormat:@"default_image.png"];
    }
    
    // Check to make sure we have a delegate and that it implements our method
    if (self.delegate && [(id)self.delegate respondsToSelector:@selector(addChristmasItemToList:)]) {
        // Send back the newly created item
        NSDictionary *newPresent = [NSDictionary dictionaryWithObjectsAndKeys:self.presentText.text, @"text", self.presentImageFileName, @"imageName", nil];
        [self.delegate addChristmasItemToList:newPresent];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
