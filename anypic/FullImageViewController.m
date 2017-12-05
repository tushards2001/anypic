//
//  FullImageViewController.m
//  anypic
//
//  Created by MacBookPro on 12/4/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "FullImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"



@interface FullImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIView *viewDescriptionBack;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnCollection;


@end

@implementation FullImageViewController

@synthesize resultDictionary;
@synthesize HUD;
@synthesize type;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([type isEqualToString:SEGUE_TYPE_SAVED])
    {
        self.btnCollection.hidden = YES;
    }
    
    self.btnCollection.enabled = NO;
    self.imageScrollView.panGestureRecognizer.enabled = NO;
    
    //NSLog(@"resultDictionary:\n%@", self.resultDictionary);
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self.resultDictionary objectForKey:@"user"]];
    
    // profile image
    NSMutableDictionary *profileImageDictionary = [[NSMutableDictionary alloc] initWithDictionary:[userDictionary objectForKey:@"profile_image"]];
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"profile_mask"] CGImage];
    mask.frame = CGRectMake(0, 0, self.profileImageView.frame.size.width, self.profileImageView.frame.size.height);
    self.profileImageView.layer.mask = mask;
    self.profileImageView.layer.masksToBounds = YES;
    
    if ([profileImageDictionary objectForKey:@"small"] != [NSNull null])
    {
        NSURL *profileImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [profileImageDictionary objectForKey:@"small"]]];
        
        [self.profileImageView sd_setImageWithURL:profileImageURL
                                 placeholderImage:[UIImage imageNamed:@"icon_user"]
                                          options:SDWebImageProgressiveDownload|SDWebImageContinueInBackground];
    }
    else
    {
        [self.profileImageView setImage:[UIImage imageNamed:@"icon_user"]];
    }
    
    
    // username
    if ([userDictionary objectForKey:@"name"] != [NSNull null])
    {
        [self.lblUsername setText:[NSString stringWithFormat:@"%@", [userDictionary objectForKey:@"name"]]];
    }
    else
    {
        [self.lblUsername setText:@"Unknown"];
    }

    
    // description
    //NSString *description = [resultDictionary objectForKey:@"description"];
    
    if ([resultDictionary objectForKey:@"description"] != [NSNull null])
    {
        [self.lblDescription setText:[resultDictionary objectForKey:@"description"]];
    }
    else
    {
        [self.viewDescriptionBack setHidden:YES];
        self.lblDescription.text = @"";
        [self.lblDescription setHidden:YES];
        
    }
    
    
    
    //scrollView
    self.imageScrollView.minimumZoomScale = 1.0;
    self.imageScrollView.maximumZoomScale = 6.0;
    //self.imageScrollView.contentSize = self.fullImageView.bounds.size;
    self.imageScrollView.delegate = self;
    self.imageScrollView.panGestureRecognizer.enabled = NO;
    
    hudVisible = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    // image
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self.resultDictionary objectForKey:@"urls"]];
    
    if ([type isEqualToString:SEGUE_TYPE_SAVED])
    {
        UIImage *fullImage = [[AppConfig sharedInstance] getImageById:[self.resultDictionary objectForKey:@"id"] suffix:@"thumb"];
        
        if (fullImage)
        {
            NSLog(@"full image already saved");
            [self.fullImageView setImage:fullImage];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageScrollView.panGestureRecognizer.enabled = YES;
            });
            
            // gesture
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            singleTap.numberOfTouchesRequired = 1;
            singleTap.numberOfTapsRequired = 1;
            [self.imageScrollView addGestureRecognizer:singleTap];
            
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
            doubleTap.numberOfTouchesRequired = 1;
            doubleTap.numberOfTapsRequired = 2;
            [self.imageScrollView addGestureRecognizer:doubleTap];
            
            [singleTap requireGestureRecognizerToFail:doubleTap];
        }
        else
        {
            //hud
            //------------------ HUD - BEGIN -------------------
            if (HUD)
            {
                [HUD removeFromSuperview];
                HUD = nil;
            }
            
            HUD = [MBProgressHUD showHUDAddedTo:self.imageScrollView animated:YES];
            HUD.delegate = self;
            HUD.mode = MBProgressHUDModeIndeterminate;
            //HUD.progress = 0.0f;
            [HUD setRemoveFromSuperViewOnHide:YES];
            //------------------ HUD - END -------------------
            
            [self.fullImageView sd_setImageWithURL:[NSURL URLWithString:[urlDictionary objectForKey:@"full"]]
                                       placeholderImage:nil
                                              completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self.HUD hideAnimated:YES];
                                                      self.btnCollection.enabled = YES;
                                                      self.imageScrollView.panGestureRecognizer.enabled = YES;
                                                  });
                                                  
                                                  // gesture
                                                  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
                                                  singleTap.numberOfTouchesRequired = 1;
                                                  singleTap.numberOfTapsRequired = 1;
                                                  [self.imageScrollView addGestureRecognizer:singleTap];
                                                  
                                                  UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
                                                  doubleTap.numberOfTouchesRequired = 1;
                                                  doubleTap.numberOfTapsRequired = 2;
                                                  [self.imageScrollView addGestureRecognizer:doubleTap];
                                                  
                                                  [singleTap requireGestureRecognizerToFail:doubleTap];
                                                  
                                                  if ([[AppConfig sharedInstance] saveImage:image imageId:[self.resultDictionary objectForKey:@"id"] suffix:@"full"])
                                                  {
                                                      NSLog(@"full image saved");
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"failed to save full image");
                                                  }
                                              }];
        }
    }
    else
    {
        //hud
        //------------------ HUD - BEGIN -------------------
        if (HUD)
        {
            [HUD removeFromSuperview];
            HUD = nil;
        }
        
        HUD = [MBProgressHUD showHUDAddedTo:self.imageScrollView animated:YES];
        HUD.delegate = self;
        HUD.mode = MBProgressHUDModeIndeterminate;
        //HUD.progress = 0.0f;
        [HUD setRemoveFromSuperViewOnHide:YES];
        //------------------ HUD - END -------------------
        
        if ([urlDictionary objectForKey:@"full"] != [NSNull null])
        {
            NSURL *fullImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urlDictionary objectForKey:@"full"]]];
            [self.fullImageView sd_setImageWithURL:fullImageURL
                                         completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                             NSLog(@"%f:%f", image.size.width, image.size.height);
                                             if (!error)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self.HUD hideAnimated:YES];
                                                     self.btnCollection.enabled = YES;
                                                     self.imageScrollView.panGestureRecognizer.enabled = YES;
                                                 });
                                                 
                                                 // gesture
                                                 UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
                                                 singleTap.numberOfTouchesRequired = 1;
                                                 singleTap.numberOfTapsRequired = 1;
                                                 [self.imageScrollView addGestureRecognizer:singleTap];
                                                 
                                                 UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
                                                 doubleTap.numberOfTouchesRequired = 1;
                                                 doubleTap.numberOfTapsRequired = 2;
                                                 [self.imageScrollView addGestureRecognizer:doubleTap];
                                                 
                                                 [singleTap requireGestureRecognizerToFail:doubleTap];
                                             }
                                             else
                                             {
                                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                                          message:error.localizedDescription
                                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                 
                                                 UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK"
                                                                                                    style:UIAlertActionStyleDefault
                                                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                                                      [self.navigationController popViewControllerAnimated:YES];
                                                                                                  }];
                                                 
                                                 [alertController addAction:actionOK];
                                                 
                                                 [self presentViewController:alertController animated:YES completion:nil];
                                             }
                                         }];
        }
    }
    
    
    
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"single tap");
    
    if (hudVisible)
    {
        hudVisible = NO;
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.headerView.alpha = 0;
                             self.footerView.alpha = 0;
                             [self setNeedsStatusBarAppearanceUpdate];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else
    {
        hudVisible = YES;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.headerView.alpha = 1;
                             self.footerView.alpha = 1;
                             [self setNeedsStatusBarAppearanceUpdate];
                         } completion:^(BOOL finished) {
                             
                         }];
    }

}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"double tap");
    
    if(self.imageScrollView.zoomScale > self.imageScrollView.minimumZoomScale)
    {
        [self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale animated:YES];
    }
    else
    {
        //[self.imageScrollView setZoomScale:self.imageScrollView.maximumZoomScale animated:YES];
        
        CGPoint touch = [recognizer locationInView:recognizer.view];
        
        CGSize scrollViewSize = self.imageScrollView.bounds.size;
        
        CGFloat w = scrollViewSize.width / self.imageScrollView.maximumZoomScale;
        CGFloat h = scrollViewSize.height / self.imageScrollView.maximumZoomScale;
        CGFloat x = touch.x-(w/2.0);
        CGFloat y = touch.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [self.imageScrollView zoomToRect:rectTozoom animated:YES];
    }

}




- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.fullImageView;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return !hudVisible;
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

- (IBAction)actionBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSave:(UIButton *)sender
{
    //NSLog(@"-------- actionSave ---------\n%@\n----------------------------------------------", self.resultDictionary);
    
    /*NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[AppConfig sharedInstance] getCollectionPLISTData]];
    [array addObject:self.resultDictionary];
    NSLog(@"array[%ld] = %@", array.count, array);*/

    BOOL saveStatus = [[AppConfig sharedInstance] addDataToCollectionPLIST:[self.resultDictionary dictionaryByReplacingNullsWithBlanks]];
    
    if (saveStatus)
    {
        //------------------------------ operation queue - begin ----------------------
        operationQueue = [NSOperationQueue new];
        
        // now playing
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(saveFullImage)
                                                                                  object:nil];
        [operationQueue addOperation:operation];
        
        // top rated
        operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                         selector:@selector(saveThumbnail)
                                                           object:nil];
        [operationQueue addOperation:operation];
        //------------------------------ operation queue - end ----------------------
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusAuthorized)
            {
                //We have permission. Do whatever is needed
                UIImageWriteToSavedPhotosAlbum(self.fullImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            else
            {
                //No permission. Trying to normally request it
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status != PHAuthorizationStatusAuthorized)
                    {
                        //User don't give us permission. Showing alert with redirection to settings
                        //Getting description string from info.plist file
                        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
                        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                        [alertController addAction:cancelAction];
                        
                        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }];
                        [alertController addAction:settingsAction];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            }
        });
    }
}

- (void)saveFullImage
{
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self.resultDictionary objectForKey:@"urls"]];
    
    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
    [imageDownloader downloadImageWithURL:[NSURL URLWithString:[urlDictionary objectForKey:@"full"]]
                                  options:SDWebImageDownloaderHighPriority
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                     //
                                 }
                                completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                    if (error)
                                    {
                                        NSLog(@"failed to save full image : %@", error);
                                    }
                                    else
                                    {
                                        if ([[AppConfig sharedInstance] saveImage:image imageId:[self.resultDictionary objectForKey:@"id"] suffix:@"full"])
                                        {
                                            NSLog(@"full image saved");
                                        }
                                        else
                                        {
                                            NSLog(@"failed to save full image");
                                        }
                                        
                                    }
                                }];
    
}

- (void)saveThumbnail
{
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self.resultDictionary objectForKey:@"urls"]];
    
    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
    [imageDownloader downloadImageWithURL:[NSURL URLWithString:[urlDictionary objectForKey:@"thumb"]]
                                  options:SDWebImageDownloaderHighPriority
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                     //
                                 }
                                completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                    if (error)
                                    {
                                        NSLog(@"failed to save thumb image : %@", error);
                                    }
                                    else
                                    {
                                        if ([[AppConfig sharedInstance] saveImage:image imageId:[self.resultDictionary objectForKey:@"id"] suffix:@"thumb"])
                                        {
                                            NSLog(@"thumb image saved");
                                        }
                                        else
                                        {
                                            NSLog(@"failed to save thumb image");
                                        }
                                        
                                    }
                                }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    
    if (error)
    {
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor redColor];
        [self.view makeToast:@"Could not save photo" duration:2.0f position:CSToastPositionCenter style:style];
    }
    else
    {
        style.messageColor = [UIColor blackColor];
        style.backgroundColor = [UIColor whiteColor];
        [self.view makeToast:@"Photo saved" duration:2.0f position:CSToastPositionCenter style:style];
        
        
    }
    
    
}





@end
