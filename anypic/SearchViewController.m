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
    
    NSDictionary *result = [notification userInfo];
    
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
    
    [self performSegueWithIdentifier:@"segue_gallery" sender:nil];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:1];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary = [arraySearchResult objectAtIndex:indexPath.row];
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[dictionary objectForKey:@"urls"]];
    
    
    NSURL *posterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urlDictionary objectForKey:@"thumb"]]];
    
    /*[thumbnailImageView sd_setImageWithURL:posterURL
                                placeholderImage:[UIImage imageNamed:@"placeholder"]];*/
    
    [thumbnailImageView sd_setImageWithURL:posterURL
                          placeholderImage:[UIImage imageNamed:@"placeholder"]
                                   options:SDWebImageProgressiveDownload|SDWebImageContinueInBackground];
    
    [thumbnailImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [thumbnailImageView.layer setBorderWidth:0.5f];
    
    
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


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cvCell" forIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    
    //CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:[collectionView superview]];
    CGRect cellFrameInSuperview = [cell convertRect:cell.frame toView:self.view];
    CGPoint cellPointInSuperview = [cell convertPoint:cell.center fromView:self.view];
    
    ImageViewer *imageView = [[ImageViewer alloc] initWithFrame:cellFrameInSuperview];
    [self.view addSubview:imageView];
    imageView.center = cellPointInSuperview;
    [UIView animateWithDuration:2.0 animations:^{
        imageView.frame =  self.view.frame;
        imageView.center = self.view.center;
    } completion:^(BOOL finished) {
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tfSearchField resignFirstResponder];
}

@end
