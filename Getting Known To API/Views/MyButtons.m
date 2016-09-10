//
//  MyButtons.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "MyButtons.h"

@implementation MyButtons

- (instancetype) initWithType:(MyButtonType)buttonType delegate:(id<MyButtonDelegate>)delegate {
    self = [super init];
    if (self) {
        self->_type = buttonType;
        self.vcDelegate = delegate;
        [self setup];
    }
    return self;
}

- (void) setup {
    [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.2]];
    [self addTarget:self action:@selector(iAmPressed) forControlEvents:UIControlEventTouchUpInside];
    if (self.type == MyButtonTypeLogIn) {
        [self setTitle:@"Log In" forState:UIControlStateNormal];
    }
}

- (void) iAmPressed{
    if (self.type == MyButtonTypeLogIn) {
        if ([self.vcDelegate respondsToSelector:@selector(logIn)]) {
            [self.vcDelegate logIn];
        }
    }
}

@end
