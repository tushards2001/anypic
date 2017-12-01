//
//  ImageViewer.m
//  anypic
//
//  Created by MacBookPro on 12/1/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "ImageViewer.h"

@implementation ImageViewer

@synthesize view;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //initialization code
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    //******************************************* DO NOT CHANGE THIS *************************************************
    [[NSBundle mainBundle] loadNibNamed:@"ImageViewer" owner:self options:nil];
    [self addSubview:self.view];
    
    // The new self.view needs autolayout constraints for sizing
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(view, self)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(view, self)]];
    //******************************************* DO NOT CHANGE THIS *************************************************

}

@end
