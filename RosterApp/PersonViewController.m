//
//  PersonViewController.m
//  RosterApp
//
//  Created by Reed Sweeney on 4/8/14.
//  Copyright (c) 2014 Reed Sweeney. All rights reserved.
//
 
#import "PersonViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Person.h"
#import "DataController.h"
#import "ScrollTopView.h"

@interface PersonViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIActionSheet *myActionSheet;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *githubField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet ScrollTopView *bgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *primaryView;


@end

@implementation PersonViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.selectedPerson.firstName, self.selectedPerson.lastName];
    self.githubField.text = self.selectedPerson.github;
    self.twitterField.text = self.selectedPerson.twitter;
  
    if (_selectedPerson.avatar)
    {
    self.imageView.image = self.selectedPerson.avatar;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.nameLabel.delegate = self;
    self.githubField.delegate = self;
    self.twitterField.delegate = self;

    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.bgView.backgroundColor = self.selectedPerson.personColor;
  
  CGFloat r, g, b, a;
  
  [self.selectedPerson.personColor getRed:&r green:&g blue:&b alpha:&a];
  
  [_r setValue:r animated:YES];
  [_g setValue:g animated:YES];
  [_r setValue:b animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.selectedPerson.firstName = [[_nameLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] firstObject];
    self.selectedPerson.lastName = [[_nameLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lastObject];
  
    self.selectedPerson.github = _githubField.text;
    self.selectedPerson.twitter = _twitterField.text;
  
  
  
    [[DataController sharedData] save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)CameraButtonPressed:(id)sender
{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.myActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        
    }
    else {
        self.myActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Choose Photo", nil];
        
    }
    
    
    [self.myActionSheet showInView:self.view];

    NSLog(@"button pressed");
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  ;
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Photo"])
    {
        self.selectedPerson.avatar = [UIImage imageNamed:@"anonymous_logo.png"];
      
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Photo"])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    } else {
        
        return;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    _imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageView.layer.cornerRadius = _imageView.frame.size.width/2.0;
    _imageView.layer.masksToBounds = YES;
    self.selectedPerson.avatar = editedImage;
    [[DataController sharedData] save];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Completed");
        
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            [assetsLibrary writeImageToSavedPhotosAlbum:editedImage.CGImage
                                            orientation:ALAssetOrientationUp
                                        completionBlock:^(NSURL *assetURL, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error, Saving Image: %@", error.localizedDescription);
                                            }
                                        }];
        } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot save photo"
                                                                message:@"Authorization status not granted"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        } else
        {
            NSLog(@"Authorization Not Determined");
        }
    }];
}

-(IBAction)sharePhoto:(id)sender
{
  UIActivityViewController *sharePhotoVC = [[UIActivityViewController alloc]initWithActivityItems:@[self.selectedPerson.avatar, [NSURL URLWithString:@"http://www.apple.com"]] applicationActivities:nil];
  
  [self presentViewController:sharePhotoVC animated:YES completion:nil];

  
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 200) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
  [self.scrollView setContentOffset:CGPointMake(0, 0)animated:YES];
}


//allows user to change the background color of the page and have the changes persist
-(IBAction)sliderValueChanged:(UISlider*)slider
{
  CGFloat r = _r.value;
  CGFloat g = _g.value;
  CGFloat b = _b.value;
  
  self.selectedPerson.personColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
  NSLog(@"%@", self.selectedPerson.personColor);
  [_bgView setBackgroundColor:self.selectedPerson.personColor];
  
}



//tap the photo and the background changes to a random color and the sliders move
- (IBAction)randomColor:(id)sender {
  
  CGFloat r = ( arc4random() % 256 / 256.0 );
  CGFloat g = ( arc4random() % 256 / 256.0 );
  CGFloat b = ( arc4random() % 256 / 256.0 );
  self.selectedPerson.personColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
  [_bgView setBackgroundColor:self.selectedPerson.personColor];
  _r.value = r;
  _g.value = g;
  _b.value = b;
//  UIImage *thumbImage = self.selectedPerson.avatar;
//  [_b setThumbImage:thumbImage forState:UIControlStateNormal];
  
  [[UISlider appearance] setThumbImage:self.selectedPerson.avatar
                              forState:UIControlStateNormal];
  
  NSLog(@" %.02f %.02f %.02f", r, g, b);
}









@end









