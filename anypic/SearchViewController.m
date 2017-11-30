//
//  SearchViewController.m
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "SearchViewController.h"


@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize tfSearchField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // tfSearchField
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search free photos.." attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.tfSearchField.attributedPlaceholder = str;
    
    self.tfSearchField.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionShowGallery:(UIButton *)sender
{
    [self.tfSearchField resignFirstResponder];
    
    [self performSegueWithIdentifier:@"segue_gallery" sender:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tfSearchField resignFirstResponder];
    
    NSString *newSearchQuery = [self.tfSearchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (newSearchQuery.length > 0)
    {
        NSLog(@"Searching for \"%@\"\n-------------------------", newSearchQuery);
    }
    
    return YES;
}


@end
