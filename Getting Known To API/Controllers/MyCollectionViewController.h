//
//  MyCollectionViewController.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 07.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <UIImageView *> *mediaArray;

- (instancetype) initWithElements: (NSArray <UIImageView *> *) elementsArray;

@end
