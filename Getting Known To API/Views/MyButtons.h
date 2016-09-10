//
//  MyButtons.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyButtonDelegate <NSObject>

@optional

- (void) logIn;

@end

typedef enum : NSUInteger {
    MyButtonTypeLogIn,
} MyButtonType;

@interface MyButtons : UIButton

@property (nonatomic, readonly) MyButtonType type;
@property (nonatomic, weak) id <MyButtonDelegate> vcDelegate;

- (instancetype) initWithType: (MyButtonType) buttonType delegate: (id <MyButtonDelegate>) delegate;

@end
