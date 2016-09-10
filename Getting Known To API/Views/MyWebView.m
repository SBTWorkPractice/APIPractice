//
//  MyWebView.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "MyWebView.h"

@implementation MyWebView

- (instancetype) initWithDelegate:(id<UIWebViewDelegate>)theDelegate {
    self = [super init];
    if (self) {
        [self setDelegate: theDelegate];
    }
    return self;
}

@end
