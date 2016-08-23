//
//  LoginViewController.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 16.08.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

- (instancetype) initWithConfirmationBlock: (void(^)()) confirmationBlock failureBlock: (void(^)()) failureBlock;

@end
