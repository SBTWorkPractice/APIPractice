//
//  MyCollectionViewCell.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

- (instancetype) initWithImageView:(UIImageView *)image {
    self = [super init];
    if (self) {
        self.imageView = image;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (BOOL) containsAnImage {
    if (self.imageView.superview == self.contentView) {
        return YES;
    } else {
        return NO;
    }
}

@end
