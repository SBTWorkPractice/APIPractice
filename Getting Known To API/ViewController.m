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
#import "MyButtons.h"
#import "SearchViewController.h"
#import "MyUserModel.h"
#import "MyCollectionViewController.h"

@interface ViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MyButtonDelegate>

@property (nonatomic, strong) MyButtons *loginButton;
@property (nonatomic, strong) InstagramEngine *engine;
@property (nonatomic, strong) MyUserModel *foundUser;
@property (nonatomic, strong) NSArray <UIImageView *> *loadedMedia;
@property (nonatomic, strong) UICollectionView *loadedMediaView;
@property (nonatomic, strong) SearchViewController *searchController;
@property (nonatomic, strong) MyCollectionViewController *collectionVC;

@end

@implementation ViewController

#pragma mark - LifeCycle

- (void) viewWillLayoutSubviews {
    self.loginButton.frame = CGRectMake(20, (self.view.frame.size.height - 40) / 2, self.view.frame.size.width - 40, 40);
    self.loadedMediaView.frame = self.view.frame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton = [[MyButtons alloc] initWithType:MyButtonTypeLogIn delegate:self];
    [self.view addSubview: self.loginButton];
    self.engine = [InstagramEngine sharedEngine];
    self.searchController = [[SearchViewController alloc] initWithDelegate: (id<SearchViewControllerDelegate>) self];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    self.loadedMediaView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout: layout];
    [self.loadedMediaView setBackgroundColor:[UIColor grayColor]];
    [self.loadedMediaView setAllowsSelection: NO];
    [self.loadedMediaView setDelegate:self];
    [self.loadedMediaView setDataSource:self];
    [self.loadedMediaView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myItem"];
}

#pragma mark - Search

- (void) startSearchForUser: (nonnull NSString *) username {
    __weak typeof(self) safeSelf = self;
    [ServerInteractionManager findAUserWithString:username usingCompletionBlock:^(NSError *error, MyUserModel *targetUser) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"No users Found!" delegate:nil cancelButtonTitle:@"Try again!" otherButtonTitles:nil];
            [alert show];
        } else {
            safeSelf.foundUser = targetUser;
            [self.searchController dismissViewControllerAnimated:YES completion:nil];
            [safeSelf loadPicturesForUser: safeSelf.foundUser];
        }
    }];
}

#pragma mark - ImageLoader

- (void) loadPicturesForUser: (MyUserModel *) user {
    [ServerInteractionManager loadMediaForUser:user withCompletionBlock:^(NSError *error, NSArray <UIImageView *> *recievedData) {
        if (recievedData) {
        self.loadedMedia = [NSArray arrayWithArray:recievedData];
            [self.searchController dismissViewControllerAnimated:YES completion:nil];
            self.collectionVC = [[MyCollectionViewController alloc] initWithElements:self.loadedMedia];
            [self presentViewController:self.collectionVC animated:YES completion:nil];
            [self.collectionVC.collectionView reloadData];
    } else if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Load failed.Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

#pragma mark - MyButtonDelegate Implementation

- (void) logIn {
    [ServerInteractionManager tryToLogInWithCompletionBlock:^(BOOL success) {
        if (success) {
            [self.loginButton removeFromSuperview];
            [self presentViewController:self.searchController animated:YES completion:nil];
        } else if (!success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Some error occurred. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }sender:self];
}

@end
