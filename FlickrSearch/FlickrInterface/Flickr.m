//
//  Flickr.m
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Flickr.h"
#import "FlickrPhoto.h"

#define kFlickrAPIKey @"789582ebc574ce30f0f0ada963485a20"

@implementation Flickr

+ (NSString *)flickrSearchURLForSearchTerm:(NSString *) searchTerm
{
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=20&format=json&nojsoncallback=1",kFlickrAPIKey,searchTerm];
}

+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size
{
    if(!size)
    {
        size = @"m";
    }
    // URL: https://farm1.staticflickr.com/591/23072645749_ba8cfa5186_m.jpg
    // Farm#: 1, Server#:591 PhotoID:23072645749 Secert: ba8cfa5186 Size:M (mega bytes)
    return [NSString stringWithFormat:@"https://farm%ld.staticflickr.com/%ld/%lld_%@_%@.jpg",flickrPhoto.farm,flickrPhoto.server,flickrPhoto.photoID,flickrPhoto.secret,size];
}

- (void)searchFlickrForTerm:(NSString *) term completionBlock:(FlickrSearchCompletionBlock) completionBlock
{
    NSString *searchURL = [Flickr flickrSearchURLForSearchTerm:term];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSURL *url = [NSURL URLWithString:[searchURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        NSLog(@"FLickr URL: %@", url);
        NSString *searchResultString = [NSString stringWithContentsOfURL:url
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
        if (error != nil) {
            completionBlock(term,nil,error);
        }
        else
        {
            // Parse the JSON Response
            /**
             * {"photos": {"page":1,"pages":4425,"perpage":20,"total":"88499","
             *
             *   photo":[
             *    {"id":"22810876324","owner":"122462637@N08","secret":"b9978fae6d",
             *      "server":"685","farm":1,"title":"@I_YansenJKT48 udah diarsip",
             *      "ispublic":1,"isfriend":0,"isfamily":0 },
             *    {"id":"23329372062","owner":"135884153@N04","secret":"ecd21485a1",
             *      "server":"5811","farm":6,"title":"Makam Raja Mataram",
             *      "ispublic":1,"isfriend":0,"isfamily":0},
             *    {"id":"22758835883","owner":"122462637@N08","secret":"0b9ceb792f",
             *      "server":"660","farm" 1,"title":"@R_AninJKT48 udah diarsip",
             *      "ispublic":1,"isfriend":0,"isfamily":0},
             *   ]},
             *  "stat":"ok"
             * }
             *
             */
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:kNilOptions
                                                                                error:&error];
            if(error != nil)
            {
                completionBlock(term,nil,error);
            }
            else
            {
                NSString * status = searchResultsDict[@"stat"];
                if ([status isEqualToString:@"fail"]) {
                    NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: searchResultsDict[@"message"]}];
                    completionBlock(term, nil, error);
                } else {
                    
                    NSArray *objPhotos = searchResultsDict[@"photos"][@"photo"];
                    NSMutableArray *flickrPhotos = [@[] mutableCopy];
                    for(NSMutableDictionary *objPhoto in objPhotos)
                    {
                        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
                        photo.farm = [objPhoto[@"farm"] intValue];
                        photo.server = [objPhoto[@"server"] intValue];
                        photo.secret = objPhoto[@"secret"];
                        photo.photoID = [objPhoto[@"id"] longLongValue];
                        
                        // Fetch the photo in the URL
                        // https://www.flickr.com/services/api/misc.urls.html
                        // https://farm1.staticflickr.com/591/23072645749_ba8cfa5186_m.jpg
                        //
                        NSString *photoURL = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
                        NSURL *url = [NSURL URLWithString:[photoURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                        
                        NSData *imageData = [NSData dataWithContentsOfURL:url
                                                                  options:0
                                                                    error:&error];
                        UIImage *image = [UIImage imageWithData:imageData];
                        photo.thumbnail = image;
                        
                        [flickrPhotos addObject:photo];
                        NSLog(@"Fetch photo URL: %@ Size:(%.0f,%.0f)", url, photo.thumbnail.size.height, photo.thumbnail.size.width);
                    }
                    
                    completionBlock(term,flickrPhotos,nil);
                }
            }
        }
    });
}

+ (void)loadImageForPhoto:(FlickrPhoto *)flickrPhoto thumbnail:(BOOL)thumbnail completionBlock:(FlickrPhotoCompletionBlock) completionBlock
{
    
    NSString *size = thumbnail ? @"m" : @"b";
    
    NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:flickrPhoto size:size];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                  options:0
                                                    error:&error];
        if(error)
        {
            completionBlock(nil,error);
        }
        else
        {
            UIImage *image = [UIImage imageWithData:imageData];
            
            if([size isEqualToString:@"m"])
            {
                flickrPhoto.thumbnail = image;
            }
            else
            {
                flickrPhoto.largeImage = image;
            }
            completionBlock(image,nil);
        }
        
    });
}

@end
