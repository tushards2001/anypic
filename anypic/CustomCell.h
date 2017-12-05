//
//  CustomCell.h
//  anypic
//
//  Created by MacBookPro on 12/2/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface CustomCell : UICollectionViewCell
{
    
    
}


@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

+ (NSString *)reuseIdentifier;

@end
