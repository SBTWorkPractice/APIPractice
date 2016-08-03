//
//  ViewController.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 29.07.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "InstagramKit.h"

@interface ViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) InstagramEngine *engine;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, assign) InstagramPaginationInfo *paginationInfo;
@property (nonatomic, assign) NSArray <InstagramUser *> *users;

@end

@implementation ViewController

- (void) viewWillLayoutSubviews {
    self.loginButton.frame = CGRectMake(20, (self.view.frame.size.height - 40) / 2, self.view.frame.size.width - 40, 40);
    self.webView.frame = self.view.frame;
    self.searchField.frame = CGRectMake(20, (self.view.frame.size.height - 100) / 2, self.view.frame.size.width - 40, 40);
    self.searchButton.frame = CGRectMake(20, self.searchField.frame.origin.y + self.searchField.frame.size.height + 20, self.view.frame.size.width - 40, 40);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton = [[UIButton alloc] init];
    [self.loginButton setBackgroundColor: [UIColor grayColor]];
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.view addSubview: self.loginButton];
    [self.loginButton addTarget:self action:@selector(tryToLogin) forControlEvents:UIControlEventTouchUpInside];
    self.engine = [InstagramEngine sharedEngine];
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = (id) self;
    self.searchButton = [[UIButton alloc] init];
    [self.searchButton setTitle: @"Search!" forState:UIControlStateNormal];
    [self.searchButton setBackgroundColor: [UIColor grayColor]];
    [self.searchButton addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
    self.searchField = [[UITextField alloc] init];
    [self.searchField setBackgroundColor: [UIColor grayColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tryToLogin {
    //[self.engine logout];
    NSURL *authURL = [self.engine authorizationURLForScope:InstagramKitLoginScopePublicContent];
    [self.loginButton removeFromSuperview];
    [self.view addSubview: self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.engine receivedValidAccessTokenFromURL:request.URL error:nil]) {
        [self loginSucceeded];
        return NO;
    }
    return YES;
}

- (void) loginSucceeded {
    [self.webView removeFromSuperview];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.searchField];
}

- (void) startSearch {
    //[self.engine searchUsersWithString:self.searchField.text withSuccess: {return;} failure:nil];
}

@end
