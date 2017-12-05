//
//  GalleryViewController.h
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConfig.h"
#import "CustomCell.h"

@interface GalleryViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSArray *collectionArray;
}

- (IBAction)actionShowSearch:(UIButton *)sender;


@end
