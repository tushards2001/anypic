//
//  SearchViewController.h
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConfig.h"
#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomCell.h"
#import "FullImageViewController.h"

@interface SearchViewController : UIViewController <UITextFieldDelegate, MBProgressHUDDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    int currentPage;
    int searchResultCount;
    int totalPages;
    NSString *searchKeyword;
    BOOL waiting;
    NSMutableArray *arraySearchResult;
}

- (IBAction)actionShowGallery:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *tfSearchField;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *lblSearchResultMessage;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;

@end
