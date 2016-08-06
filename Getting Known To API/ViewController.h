//
//  ViewController.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 29.07.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"

@interface ViewController : UIViewController

- (void) loginSucceeded;
- (void) loadPicturesForUser: (InstagramUser *) user;
- (void) sortMedia: (NSMutableArray <InstagramMedia *> *) media;

@end

