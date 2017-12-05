//
//  GalleryViewController.m
//  anypic
//
//  Created by MacBookPro on 11/30/17.
//  Copyright © 2017 basicdas. All rights reserved.
//

#import "GalleryViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FullImageViewController.h"

@interface GalleryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // register custom cell nib
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[CustomCell reuseIdentifier]];
    
    self.lblMessage.text = @"";
    self.photoCollectionView.hidden = YES;
    self.lblMessage.hidden = YES;
    
    // check if collection.plist file is created
    if ([[AppConfig sharedInstance] collectionPLISTCreated])
    {
        NSLog(@"%@ FILE EXISTS", COLLECTION_PLIST);
        [self readCollection];
    }
    else
    {
        NSLog(@"%@ FILE DOES NOT EXISTS.", COLLECTION_PLIST);
        if ([[AppConfig sharedInstance] createCollectionPLIST])
        {
            NSLog(@"%@ FILE CREATED SUCCESSFULLY", COLLECTION_PLIST);
            [self readCollection];
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

- (void)readCollection
{
    NSDictionary *data = [[AppConfig sharedInstance] getCollectionPLISTData];
    
    collectionArray = [[NSArray alloc] initWithArray:[data objectForKey:@"collection"]];
    
    NSLog(@"collectionArray[%ld]", collectionArray.count);
    
    if (collectionArray.count > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoCollectionView.hidden = NO;
            self.lblMessage.hidden = YES;
            
            [self.photoCollectionView reloadData];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoCollectionView.hidden = YES;
            self.lblMessage.hidden = NO;
            
            self.lblMessage.text = @"You don't have any photos saved.";
        });
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
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

- (IBAction)actionShowSearch:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionArray)
    {
        return [collectionArray count];
    }
    else
    {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = (CustomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[CustomCell reuseIdentifier] forIndexPath:indexPath];
    
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[collectionArray objectAtIndex:indexPath.row]];
    
    NSMutableDictionary *urlDictionary = [[NSMutableDictionary alloc] initWithDictionary:[dictionary objectForKey:@"urls"]];
    
    UIImage *thumbImage = [[AppConfig sharedInstance] getImageById:[dictionary objectForKey:@"id"] suffix:@"thumb"];
    
    if (thumbImage)
    {
        NSLog(@"thumb image already saved");
        [cell.thumbnailImageView setImage:thumbImage];
    }
    else
    {
        NSLog(@"downloading thumb");
        NSURL *posterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [urlDictionary objectForKey:@"thumb"]]];
        
        [cell.thumbnailImageView sd_setImageWithURL:posterURL
                                   placeholderImage:[UIImage imageNamed:@"placeholder"]
                                            options:SDWebImageProgressiveDownload|SDWebImageContinueInBackground];
        
        [cell.thumbnailImageView sd_setImageWithURL:posterURL
                                   placeholderImage:[UIImage imageNamed:@"placeholder"]
                                          completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                              if ([[AppConfig sharedInstance] saveImage:image imageId:[dictionary objectForKey:@"id"] suffix:@"thumb"])
                                              {
                                                  NSLog(@"thumb image saved");
                                              }
                                              else
                                              {
                                                  NSLog(@"failed to save thumb image");
                                              }
                                          }];
    }
    
    
    
    [cell.thumbnailImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.thumbnailImageView.layer setBorderWidth:0.5f];
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = [[UIScreen mainScreen] bounds].size.width/IMAGES_PER_ROW;
    return CGSizeMake(cellWidth, cellWidth);
}






#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"show image");
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[collectionArray objectAtIndex:indexPath.row]];
    
    [self performSegueWithIdentifier:@"segue_fullimage" sender:dictionary];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segue_fullimage"])
    {
        FullImageViewController *vc = [segue destinationViewController];
        vc.resultDictionary = (NSDictionary *)sender;
        vc.type = SEGUE_TYPE_SAVED;
    }
}


@end
