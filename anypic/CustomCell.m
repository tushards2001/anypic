//
//  CustomCell.m
//  anypic
//
//  Created by MacBookPro on 12/2/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "CustomCell.h"


@implementation CustomCell

@synthesize thumbnailImageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (NSString *)reuseIdentifier
{
    return @"CustomCellIdentifier";
}



@end
