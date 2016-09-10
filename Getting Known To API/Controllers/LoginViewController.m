//
//  LoginViewController.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 16.08.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "LoginViewController.h"
#import "ServerInteractionManager.h"
#import "InstagramEngine.h"
#import "MyWebView.h"

@interface LoginViewController () <ServerInteractionManagerLoginDelegate, UIWebViewDelegate>

@property (nonatomic, strong, readonly) MyWebView *webView;
@property (nonatomic, strong) void (^confirmationBlock)();
@property (nonatomic, strong) void (^failureBlock)();

@end

@implementation LoginViewController

- (instancetype) initWithConfirmationBlock: (void(^)()) confirmationBlock failureBlock: (void(^)()) failureBlock {
    self = [super init];
    if (self) {
        self.confirmationBlock = confirmationBlock;
        self.failureBlock = failureBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self->_webView = [[MyWebView alloc] initWithDelegate: self];
    [self.view addSubview:self.webView];
}

- (void) viewWillLayoutSubviews {
    self.webView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
}

- (void) performLoginWithURL:(NSURL *)url{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[InstagramEngine sharedEngine] receivedValidAccessTokenFromURL:request.URL error:nil]) {
        [self.webView removeFromSuperview];
        self.confirmationBlock();
        return NO;
    } else if ([request.URL isEqual: @"https://google.com"]) {
        [self.webView removeFromSuperview];
        self.failureBlock();
        return NO;
    }
    return YES;
}


@end
