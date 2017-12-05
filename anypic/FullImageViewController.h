//
//  FullImageViewController.h
//  anypic
//
//  Created by MacBookPro on 12/4/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "AppConfig.h"
#import <Toast/UIView+Toast.h>
#import <Photos/Photos.h>

@interface FullImageViewController : UIViewController <UIScrollViewDelegate, MBProgressHUDDelegate>
{
    BOOL hudVisible;
    
    NSOperationQueue *operationQueue;
}

@property (strong, nonatomic) NSDictionary *resultDictionary;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) MBProgressHUD *HUD;

@end
