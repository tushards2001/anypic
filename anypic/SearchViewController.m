//
//  SearchViewController.m
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "SearchViewController.h"


@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize tfSearchField;
@synthesize HUD;
@synthesize lblMessage;
@synthesize lblSearchResultMessage;
@synthesize viewFooter;
@synthesize photoCollectionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // lblSearchResultMessage
    self.lblSearchResultMessage.text = @"Search for high resolutions images";
    
    // photosCollectionView
    self.photoCollectionView.hidden = YES;
    
    // tfSearchField
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search free photos..." attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.tfSearchField.attributedPlaceholder = str;
    self.tfSearchField.delegate = self;
    
    // footer view
    [self hideFooter];
    
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[CustomCell reuseIdentifier]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

- (void)searchPhotosWithKeyword:(NSString *)keyword
{
    currentPage = 1;
    searchResultCount = 0;
    totalPages = 0;
    
    waiting = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblSearchResultMessage.hidden = YES;
    });
    
    
    // array search result
    if (arraySearchResult)
    {
        [arraySearchResult removeAllObjects];
        arraySearchResult = nil;
    }
    
    arraySearchResult = [[NSMutableArray alloc] init];
    
    //------------------ HUD - BEGIN -------------------
    if (HUD)
    {
        [HUD removeFromSuperview];
        HUD = nil;
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD setRemoveFromSuperViewOnHide:YES];
    //------------------ HUD - END -------------------
    
    // add notification handler
    [self addNotificationObserverForPhotoSearch];
    
    // search photos
    [[AppConfig sharedInstance] UnsplashSearchPhotoByKeyword:keyword page:currentPage];
}

- (void)loadMorePhotos:(NSString *)keyword nextPage:(int)nextPage
{
    // add notification handler
    [self addNotificationObserverForPhotoSearch];
    
    [[AppConfig sharedInstance] UnsplashSearchPhotoByKeyword:keyword page:nextPage];
}

- (void)UnsplashSearchResultNotification:(NSNotification *)notification
{
    waiting = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (HUD)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    });
    
    //NSDictionary *result = [notification userInfo];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
    //NSLog(@"----------------------- result -------------------------\n%@\n----------------------------------------------", result);
    
    searchResultCount = [[result objectForKey:@"total"] intValue];
    totalPages = [[result objectForKey:@"total_pages"] intValue];
    
    if (searchResultCount > 0)
    {
        NSLog(@"Total: %d", searchResultCount);
        NSLog(@"Pages: %d", totalPages);
        //arraySearchResult = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"results"]];
        [arraySearchResult addObjectsFromArray:[result objectForKey:@"results"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoCollectionView.hidden = NO;
            [self.photoCollectionView reloadData];
        });
        
        [self showFooterWithMessage:[NSString stringWithFormat:@"Found %d photos for \"%@\"", searchResultCount, [searchKeyword stringByReplacingOccurrencesOfString:@"%20" withString:@" "]]];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.photoCollectionView.hidden)
            {
                [self.photoCollectionView setHidden:YES];
            }
            
            [self.lblSearchResultMessage setHidden:NO];
            [self.lblSearchResultMessage setText:[NSString stringWithFormat:@"No photos found for \"%@\"", [searchKeyword stringByReplacingOccurrencesOfString:@"%20" withString:@" "]]];
            [self.tfSearchField setText:@""];
            searchKeyword = @"";
        });
        
        
    }
 
    [self removeNotificationObserverForPhotoSearch];
}

- (void)UnsplashSearchError:(NSNotification *)notification
{
    waiting = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (HUD)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    });
    
    NSLog(@"Error: %@", [[notification userInfo] objectForKey:@"error"]);
    [self removeNotificationObserverForPhotoSearch];
    
    [self showUIAlertControllerWithTitle:@"Error" message:[[notification userInfo] objectForKey:@"error"]];
}

- (IBAction)actionShowGallery:(UIButton *)sender
{
    [self.tfSearchField resignFirstResponder];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized)
        {
            //We have permission. Do whatever is needed
            [self performSegueWithIdentifier:@"segue_gallery" sender:nil];
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

- (void)showUIAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action)
                               {
                                   // code
                               }];
    
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showFooterWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lblMessage setText:message];
        [self.viewFooter setHidden:NO];
    });
}

- (void)hideFooter
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewFooter.hidden = YES;
        [self.lblMessage setText:@""];
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tfSearchField resignFirstResponder];
    
    NSString *newSearchQuery = [self.tfSearchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (newSearchQuery.length > 0)
    {
        NSLog(@"Searching for \"%@\"\n-------------------------", newSearchQuery);

        if (searchKeyword.length > 0)
        {
            NSString *previousSearchKeyword = searchKeyword;
            searchKeyword = [newSearchQuery stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            if (![previousSearchKeyword isEqualToString:searchKeyword])
            {
                if (arraySearchResult) {
                    [arraySearchResult removeAllObjects];
                    arraySearchResult = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.photoCollectionView reloadData];
                    self.photoCollectionView.hidden = YES;
                    [self hideFooter];
                    //[self.photoCollectionView setContentOffset:CGPointZero animated:NO];
                    
                    /*if ([self.photoCollectionView numberOfItemsInSection:0] > 0)
                    {
                        [self.photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                                         atScrollPosition:UICollectionViewScrollPositionTop
                                                                 animated:NO];
                    }*/
                });
                
                searchKeyword = [newSearchQuery stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                [self searchPhotosWithKeyword:searchKeyword];
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoCollectionView.hidden = YES;
                [self hideFooter];
                /*if ([self.photoCollectionView numberOfItemsInSection:0] > 0)
                {
                    [self.photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                                     atScrollPosition:UICollectionViewScrollPositionTop
                                                             animated:NO];
                }*/
            });
            
            searchKeyword = [newSearchQuery stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            [self searchPhotosWithKeyword:searchKeyword];
        }
        
        
    }
    
    return YES;
}

#pragma mark - CollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (arraySearchResult)
    {
        return [arraySearchResult count];
    }
    else
    {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = (CustomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[CustomCell reuseIdentifier] forIndexPath:indexPath];
    /*UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:1];*/
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[arraySearchResult objectAtIndex:indexPath.row]];
    //NSLog(@"dictionary = %@", dictionary);
    //dictionary = [arraySearchResult objectAtIndex:indexPath.row];
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[dictionary objectForKey:@"urls"]];
    
    
    NSURL *posterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urlDictionary objectForKey:@"thumb"]]];
    
    /*[thumbnailImageView sd_setImageWithURL:posterURL
                                placeholderImage:[UIImage imageNamed:@"placeholder"]];*/
    
    [cell.thumbnailImageView sd_setImageWithURL:posterURL
                          placeholderImage:[UIImage imageNamed:@"placeholder"]
                                   options:SDWebImageProgressiveDownload|SDWebImageContinueInBackground];
    
    [cell.thumbnailImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.thumbnailImageView.layer setBorderWidth:0.5f];
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = [[UIScreen mainScreen] bounds].size.width/IMAGES_PER_ROW;
    return CGSizeMake(cellWidth, cellWidth);
}



- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"indexPath.row = %ld | currentPage = %d | totalPages = %d | waiting = %@", (long)indexPath.row, currentPage, totalPages, waiting?@"Yes":@"No");
    
    if (indexPath.row == [arraySearchResult count] - 1 && waiting == NO)
    {
        if (currentPage < totalPages)
        {
            waiting = YES;
            currentPage++;
            NSLog(@"nextPage = %d", currentPage);
            [self loadMorePhotos:searchKeyword nextPage:currentPage];
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"cvFooter"
                                                                                         forIndexPath:indexPath];
        
        UIActivityIndicatorView *activityIndicator = [footerview viewWithTag:2];
        UILabel *lblFooterMessage = [footerview viewWithTag:3];
        
        if (waiting)
        {
            if (![activityIndicator isAnimating])
            {
                [activityIndicator startAnimating];
            }
            
            activityIndicator.hidden = NO;
            
            lblFooterMessage.hidden = YES;
            lblFooterMessage.text = @"";
        }
        else
        {
            [activityIndicator stopAnimating];
            activityIndicator.hidden = YES;
            
            lblFooterMessage.hidden = NO;
            
            if (currentPage == totalPages)
            {
                lblFooterMessage.text = @"No more photos to show.";
            }
            else
            {
                lblFooterMessage.text = @"Scroll up to load more photos.";
            }
        }
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segue_fullimage"])
    {
        FullImageViewController *vc = [segue destinationViewController];
        vc.resultDictionary = (NSDictionary *)sender;
        vc.type = SEGUE_TYPE_ONLINE;
    }
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"show image");
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[arraySearchResult objectAtIndex:indexPath.row]];
    //dictionary = [arraySearchResult objectAtIndex:indexPath.row];
    //NSLog(@"-------- self.resultDictionary ---------\n%@", dictionary);
    
    [self performSegueWithIdentifier:@"segue_fullimage" sender:dictionary];
    
    /*ImageViewer *imageViewer = [[ImageViewer alloc] initWithFrame:self.view.frame resultDictionary:dictionary];
    [self.view addSubview:imageViewer];*/
    
    /*UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes * theAttributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect cellFrameInSuperview = [collectionView convertRect:theAttributes.frame toView:[collectionView superview]];
    
    
    ImageViewer *imageViewer = [[ImageViewer alloc] initWithFrame:cellFrameInSuperview];
    [self.view addSubview:imageViewer];
    imageViewer.imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageViewer.imageView.clipsToBounds = YES;
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary = [arraySearchResult objectAtIndex:indexPath.row];
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[dictionary objectForKey:@"urls"]];
    
    
    NSURL *posterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urlDictionary objectForKey:@"thumb"]]];
    
    [thumbnailImageView sd_setImageWithURL:posterURL
     placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [imageViewer.imageView sd_setImageWithURL:posterURL
                          placeholderImage:[UIImage imageNamed:@"placeholder"]
                                   options:SDWebImageProgressiveDownload|SDWebImageContinueInBackground];
    
    [UIView animateWithDuration:2.0 animations:^{
        imageViewer.frame =  self.view.frame;
        //imageViewer.center = self.view.center;
    } completion:^(BOOL finished) {
    }];*/
    
    /*CustomCell *cell = (CustomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[CustomCell reuseIdentifier] forIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes * theAttributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellFrameInSuperview = [collectionView convertRect:theAttributes.frame toView:[collectionView superview]];
    
    ImageViewer *imageViewer = [[ImageViewer alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageViewer];
    //imageViewer.imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageViewer.originalImageRect = cellFrameInSuperview;
    //imageViewer.imageView.clipsToBounds = YES;
    //[imageViewer showImageFrom:cell.thumbnailImageView img:cell.thumbnailImageView.image];
    NSLog(@"%@", cell.thumbnailImageView.image?@"Yes":@"No");*/
    
    
    
    
    
    /*UIImageView *iv = [[UIImageView alloc] init];
    [imageViewer addSubview:iv];
    iv.frame = cellFrameInSuperview;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.clipsToBounds = YES;
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary = [arraySearchResult objectAtIndex:indexPath.row];
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[dictionary objectForKey:@"urls"]];
    
    
    NSURL *posterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urlDictionary objectForKey:@"thumb"]]];
    
    [iv sd_setImageWithURL:posterURL
                             placeholderImage:[UIImage imageNamed:@"placeholder"]
                                      options:SDWebImageProgressiveDownload|SDWebImageContinueInBackground];
    
    [UIView animateWithDuration:4.0 animations:^{
        iv.frame = self.view.bounds;
        iv.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        
    }];*/
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tfSearchField resignFirstResponder];
}

@end
