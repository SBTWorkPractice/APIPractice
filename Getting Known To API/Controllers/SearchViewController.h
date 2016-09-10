//
//  SearchViewController.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 02.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewControllerDelegate <NSObject>

@required

- (void) startSearchForUser: (nonnull NSString *) username;

@end

@interface SearchViewController : UIViewController

@property (nonatomic, weak) id<SearchViewControllerDelegate> delegate;

- (instancetype) initWithDelegate: (id<SearchViewControllerDelegate>) theDelegate;

@end
