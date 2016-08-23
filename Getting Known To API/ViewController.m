//
//  ViewController.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 29.07.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFImageDownloader.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramKit.h"
#import "LoginViewController.h"
#import "ServerInteractionManager.h"


@interface ViewController () <UIWebViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) InstagramEngine *engine;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) InstagramUser *foundUser;
@property (nonatomic, strong) NSArray <UIImageView *> *loadedMedia;
@property (nonatomic, strong) UICollectionView *loadedMediaView;
@property (nonatomic, strong) UITextView *errorView;

@end

@implementation ViewController

#pragma mark - LifeCycle

- (void) viewWillLayoutSubviews {
    self.loginButton.frame = CGRectMake(20, (self.view.frame.size.height - 40) / 2, self.view.frame.size.width - 40, 40);
    self.webView.frame = self.view.frame;
    self.searchField.frame = CGRectMake(20, (self.view.frame.size.height - 100) / 2, self.view.frame.size.width - 40, 40);
    self.searchButton.frame = CGRectMake(20, self.searchField.frame.origin.y + self.searchField.frame.size.height + 20, self.view.frame.size.width - 40, 40);
    self.loadedMediaView.frame = self.view.frame;
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
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    self.loadedMediaView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout: layout];
    [self.loadedMediaView setBackgroundColor:[UIColor grayColor]];
    [self.loadedMediaView setAllowsSelection: NO];
    [self.loadedMediaView setDelegate:self];
    [self.loadedMediaView setDataSource:self];
    [self.loadedMediaView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myItem"];
}

#pragma mark - webViewDelegate Realisation

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.engine receivedValidAccessTokenFromURL:request.URL error:nil]) {
        [self loginSucceeded];
        return NO;
    }
    return YES;
}

#pragma mark - Login

-(void) tryToLogin {
    [ServerInteractionManager tryToLogInWithCompletionBlock:^(BOOL success) {
        if (success) {
        [self.loginButton removeFromSuperview];
        [self.view addSubview:self.searchButton];
        [self.view addSubview:self.searchField];
        } else if (!success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Some error occurred. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }sender:self];
//    [self.engine logout];
//    NSURL *authURL = [self.engine authorizationURLForScope:InstagramKitLoginScopePublicContent];
//    [self.loginButton removeFromSuperview];
//    [self.view addSubview: self.webView];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
//    LoginViewController *LoginVC = [LoginViewController new];
//    [self presentViewController:LoginVC animated:YES completion:nil];
}

//- (void) loginSucceeded {
//    [self.webView removeFromSuperview];
//    [self.view addSubview:self.searchButton];
//    [self.view addSubview:self.searchField];
//}

#pragma mark - Search

- (void) startSearch {
    self.foundUser = [ServerInteractionManager findAUserWithString:self.searchField.text];
        if (self.foundUser) {
            [self.searchField removeFromSuperview];
            [self.searchButton removeFromSuperview];
            [self loadPicturesForUser: self.foundUser];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No users Found!" delegate:nil cancelButtonTitle:@"Try again!" otherButtonTitles:nil];
            [alert show];
        }
}

#pragma mark - ImageLoader

- (void) loadPicturesForUser: (InstagramUser *) user {
    [self.view addSubview:self.loadedMediaView];
    [ServerInteractionManager loadMediaForUser:user withCompletionBlock:^(NSError *error, NSArray <UIImageView *> *recievedData) {
        if (recievedData) {
        self.loadedMedia = [NSArray arrayWithArray:recievedData];
        [self.loadedMediaView reloadData];
    } else if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Load failed.Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout Realisaton

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(75, 75);
}

#pragma mark - UICollectionViewDataSource Realisation

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return 16;
    return [self.loadedMedia count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleSelector = @"myItem";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleSelector forIndexPath:indexPath];
    BOOL hasImage = ([self viewContainsImage:cell.contentView]);
    if (!hasImage) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[[self.loadedMedia objectAtIndex:indexPath.item] image]];
        [cell.contentView addSubview:image];
    }
    
    return cell;
}

- (BOOL) viewContainsImage:(UIView*)superview {
    for (UIView *view in superview.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            return YES;
        }
    }
    return NO;
}

@end
