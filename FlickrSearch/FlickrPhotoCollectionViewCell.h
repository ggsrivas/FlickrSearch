//
//  FlickrPhotoCollectionViewCell.h
//  FlickrSearch
//
//  Created by Ajay Thakur on 12/1/15.
//  Copyright © 2015 Ajay Thaur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FlickrPhoto;

@interface FlickrPhotoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) FlickrPhoto *photo;
@end
