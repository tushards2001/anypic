//
//  ViewController.m
//  anypic
//
//  Created by MacBookPro on 11/29/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self authorizeApp];
    //[self searchPhoto];
}



- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(showSearchVC:) withObject:nil afterDelay:1.0f];
}

- (void)showSearchVC:(id)sender
{
    [self performSegueWithIdentifier:@"segue_search" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)searchPhoto
{
    [self addNotificationObserverForPhotoSearch];
    [[AppConfig sharedInstance] UnsplashSearchPhotoByKeyword:@"food"];
}

- (void)UnsplashSearchResultNotification:(NSNotification *)notification
{
    NSDictionary *result = [notification userInfo];
    NSLog(@"Total: %@", [result objectForKey:@"total"]);
    NSLog(@"Pages: %@", [result objectForKey:@"total_pages"]);
    
    [self removeNotificationObserverForPhotoSearch];
}

- (void)UnsplashSearchError:(NSNotification *)notification
{
    NSLog(@"Error: %@", [[notification userInfo] objectForKey:@"error"]);
    [self removeNotificationObserverForPhotoSearch];
}

- (void)addNotificationObserverForPhotoSearch
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UnsplashSearchResultNotification:)
                                                 name:@"UnsplashSearchResultNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UnsplashSearchError:)
                                                 name:@"UnsplashSearchErrorNotification"
                                               object:nil];
}

- (void)removeNotificationObserverForPhotoSearch
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UnsplashSearchResultNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UnsplashSearchErrorNotification" object:nil];
}

@end
