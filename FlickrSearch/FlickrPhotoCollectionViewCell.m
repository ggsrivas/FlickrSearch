//
//  FlickrPhotoCollectionViewCell.m
//  FlickrSearch
//
//  Created by Ajay Thakur on 12/1/15.
//  Copyright © 2015 Ajay Thaur. All rights reserved.
//

#import "FlickrPhotoCollectionViewCell.h"
#import "FlickrPhoto.h"

@implementation FlickrPhotoCollectionViewCell

- (void) setPhoto:(FlickrPhoto *)photo {
    
    if(_photo != photo) {
        _photo = photo;
    }
    self.imageView.image = _photo.thumbnail;
}

@end
