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
    
    //delete later
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", COLLECTION_PLIST]];
    
    [FCFileManager removeFilesInDirectoryAtPath:documentsDirectory];
    
    if ([FCFileManager isFileItemAtPath:path])
    {
        NSError *error;
        
        if ([FCFileManager removeItemAtPath:path error:&error])
        {
            NSLog(@"%@ DELETED", COLLECTION_PLIST);
        }
        else
        {
            NSLog(@"FAILED TO DELETE %@", COLLECTION_PLIST);
        }
    }*/
    //delete later
    
    if ([[AppConfig sharedInstance] collectionPLISTCreated])
    {
        NSLog(@"%@ FILE EXISTS", COLLECTION_PLIST);
        [self performSelector:@selector(showSearchVC:) withObject:nil afterDelay:1.0f];
    }
    else
    {
        NSLog(@"%@ FILE DOES NOT EXISTS.", COLLECTION_PLIST);
        if ([[AppConfig sharedInstance] createCollectionPLIST])
        {
            NSLog(@"%@ FILE CREATED SUCCESSFULLY", COLLECTION_PLIST);
            [self performSelector:@selector(showSearchVC:) withObject:nil afterDelay:1.0f];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                     message:@"Could not create user file"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                             }];
            
            [alertController addAction:actionOK];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}





/*- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(showSearchVC:) withObject:nil afterDelay:1.0f];
}*/

- (void)showSearchVC:(id)sender
{
    [self performSegueWithIdentifier:@"segue_search" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
