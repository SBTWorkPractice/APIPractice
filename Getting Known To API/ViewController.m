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

@interface ViewController () <UIWebViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) InstagramEngine *engine;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, weak)   InstagramPaginationInfo *paginationInfo;
@property (nonatomic, weak)   NSArray <InstagramUser *> *foundUsers;
@property (nonatomic, weak)   NSMutableArray <InstagramMedia *> *mediaInfo;
@property (nonatomic, strong)   NSMutableArray <UIImageView *> *loadedMedia;
@property (nonatomic, strong) UICollectionView *loadedMediaView;

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
    self.loadedMediaView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout: [UICollectionViewFlowLayout new]];
    [self.loadedMediaView setBackgroundColor:[UIColor grayColor]];
    [self.loadedMediaView setAllowsSelection: NO];
    self.loadedMediaView.delegate = (id) self;
    self.loadedMediaView.dataSource = (id) self;
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
    [self.engine logout];
    NSURL *authURL = [self.engine authorizationURLForScope:InstagramKitLoginScopePublicContent];
    [self.loginButton removeFromSuperview];
    [self.view addSubview: self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
}

- (void) loginSucceeded {
    [self.webView removeFromSuperview];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.searchField];
}

#pragma mark - Search

- (void) startSearch {
    [self.engine searchUsersWithString:self.searchField.text withSuccess: ^(NSArray <InstagramUser *> __weak *users, InstagramPaginationInfo __weak *paginationInfo){
        self.foundUsers = [NSArray arrayWithArray: [users copy]];
        NSLog(@"Search Succeeded, users List: %@", self.foundUsers);
        self.paginationInfo = paginationInfo;
        [self.searchField removeFromSuperview];
        [self.searchButton removeFromSuperview];
        if (self.foundUsers.count > 0) {
            [self loadPicturesForUser: [self.foundUsers objectAtIndex: 0]];
            [self.view addSubview:self.loadedMediaView];
            [self.loadedMediaView reloadData];
            NSLog(@"Media: %@", self.loadedMedia);
        }
    }failure: ^(NSError *error, NSInteger serverStatusCode) {NSLog(@"Search Failed, code: %li", (long)serverStatusCode);}];
}

#pragma mark - ImageLoader

- (void) loadPicturesForUser: (InstagramUser *) user {
    NSThread *loadThread = [NSThread new];
    [loadThread start];
    [self.engine
     getMediaForUser:user.Id
     withSuccess:^(NSArray <InstagramMedia *> * __weak media, InstagramPaginationInfo * _Nonnull paginationInfo) {
         NSLog(@"Media Successfully Loaded!");
         self.mediaInfo = [NSMutableArray arrayWithArray:media];
         [self sortMedia: self.mediaInfo];
     }
     failure:^(NSError * _Nonnull error, NSInteger serverStatusCode) {}];
    [loadThread cancel];
}

- (void) sortMedia: (NSMutableArray <InstagramMedia *> *)media{
    NSLog(@"Started Sorting");
    BOOL isSorted = NO;
    InstagramMedia __weak *mediaBuffer;
    for (int i = 0; i < media.count; i++) {
        if (media[i].isVideo == YES) {
            [media removeObjectAtIndex:i];
        }
    }
    while (!isSorted) {
            isSorted = YES;
        for (int i = 1; i < media.count; i++) {
            if (media[i - 1].likesCount < media[i].likesCount){
                isSorted = NO;
                mediaBuffer = media[i - 1];
                media[i - 1] = media[i];
                media[i] = mediaBuffer;
            }
        }
    }
    NSLog(@"Sorting Completed!");
    for (int i = 0; i < media.count; i++){
        NSLog(@"Position: %i, Likes Count: %li", i, (long)media[i].likesCount);
    }
    self.loadedMedia = [NSMutableArray arrayWithCapacity:media.count];
    for (int i = 0; i < media.count; i++) {
        self.loadedMedia[i] = [UIImageView new];
        [self.loadedMedia[i] setImageWithURL: media[i].standardResolutionImageURL];
    }
}

#pragma mark - UICollectionViewDelegate Realisaton

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.loadedMedia.count;
}

#pragma mark - UICollectionViewDataSource Realisation

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.loadedMedia.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleSelector = @"myItem";
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:simpleSelector];
    UICollectionViewCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleSelector forIndexPath:indexPath];
    UIImageView *cellView = (UIImageView *)[cell viewWithTag:10];
    cellView = self.loadedMedia[indexPath.item];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    return cell;
}

@end
