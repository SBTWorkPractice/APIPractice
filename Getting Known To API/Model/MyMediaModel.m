//
//  MyMediaModel.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 07.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "MyMediaModel.h"
#import "InstagramMedia.h"

@implementation MyMediaModel

- (instancetype) initWithMedia:(InstagramMedia *)media {
    self = [super init];
    if (self) {
        self->_isVideo = media.isVideo;
        self->_likesCount = media.likesCount;
        self->_thumbnailURL = [media.thumbnailURL copy];
    }
    return self;
}

@end
