//
//  MyMediaModel.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 07.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InstagramMedia;

@interface MyMediaModel : NSObject

@property (nonatomic, readonly) NSInteger likesCount;
@property (nonatomic, readonly) NSURL *thumbnailURL;
@property (nonatomic, readonly) BOOL isVideo;

- (instancetype) initWithMedia: (InstagramMedia *) media;

@end
