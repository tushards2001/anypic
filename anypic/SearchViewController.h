//
//  SearchViewController.h
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITextFieldDelegate>
{
    
}

- (IBAction)actionShowGallery:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *tfSearchField;


@end
