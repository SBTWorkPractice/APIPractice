//
//  MyCollectionViewCell.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

- (instancetype) initWithImageView: (UIImageView *) image;
- (BOOL) containsAnImage;

@end
