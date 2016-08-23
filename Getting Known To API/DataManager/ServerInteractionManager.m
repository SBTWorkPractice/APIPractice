//
//  ServerInteractionManager.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 16.08.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "ServerInteractionManager.h"
#import "InstagramKit.h"
#import "LoginViewController.h"
#import "UIImageView+AFNetworking.h"

@implementation ServerInteractionManager

+ (void) tryToLogInWithCompletionBlock:(void(^)(BOOL success))completionBlock sender: (UIViewController *) sender {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    LoginViewController <ServerInteractionManagerLoginDelegate> *loginVC;
    
    void (^confirmationBlock)(void);
    confirmationBlock = ^(){
        [sender dismissViewControllerAnimated:YES completion:nil];
        completionBlock(YES);
    };
    void (^failureBlock)(void);
    failureBlock = ^() {
        [sender dismissViewControllerAnimated:YES completion:nil];
        completionBlock(NO);
    };
    loginVC = [[LoginViewController <ServerInteractionManagerLoginDelegate> alloc] initWithConfirmationBlock:confirmationBlock failureBlock:failureBlock];
    //[engine logout];
    NSURL *authURL = [engine authorizationURLForScope:InstagramKitLoginScopePublicContent];
    [sender presentViewController:loginVC animated:YES completion:nil];
    if ([loginVC respondsToSelector:@selector(performLoginWithURL:)]) {
        [loginVC performLoginWithURL:authURL];
    }
}

+ (InstagramUser *) findAUserWithString:(NSString *)searchString {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    InstagramUser * __block __strong targetUser;
    [[InstagramEngine sharedEngine] searchUsersWithString:searchString withSuccess:^(NSArray<InstagramUser *> *users, InstagramPaginationInfo *paginationInfo) {
        NSLog(@"Found Users: %@", users);
        targetUser = [users[0] copy];
    } failure:^(NSError * _Nonnull error, NSInteger serverStatusCode) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error in searching for users. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }];
    return targetUser;
}

+ (void) loadMediaForUser:(InstagramUser *)user withCompletionBlock:(void(^)(NSError *error, NSArray <UIImageView *> *recievedData))completionBlock {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    //[self.view addSubview:self.loadedMediaView];
    NSMutableArray <UIImageView *> * __block __strong loadedMedia;
    [engine
     getMediaForUser:user.Id
     withSuccess:^(NSArray <InstagramMedia *> *media, InstagramPaginationInfo *paginationInfo) {
         NSLog(@"Media Successfully Loaded!");
         //NSLog(@"Media: %@", self.loadedMedia);NSLog(@"Started Sorting");
         NSMutableArray <InstagramMedia *> *mutableMedia = [media mutableCopy];
         BOOL isSorted = NO;
         InstagramMedia __weak *mediaBuffer;
         for (int i = 0; i < mutableMedia.count; i++) {
             if (media[i].isVideo == YES) {
                 [mutableMedia removeObjectAtIndex:i];
             }
         }
         while (!isSorted) {
             isSorted = YES;
             for (int i = 1; i < mutableMedia.count; i++) {
                 if (mutableMedia[i - 1].likesCount < mutableMedia[i].likesCount){
                     isSorted = NO;
                     mediaBuffer = mutableMedia[i - 1];
                     mutableMedia[i - 1] = mutableMedia[i];
                     mutableMedia[i] = mediaBuffer;
                 }
             }
         }
         NSLog(@"Sorting Completed!");
         for (int i = 0; i < mutableMedia.count; i++){
             NSLog(@"Position: %i, Likes Count: %li", i, (long)mutableMedia[i].likesCount);
         }
         loadedMedia = [NSMutableArray arrayWithCapacity:mutableMedia.count];
         dispatch_group_t group = dispatch_group_create();
         for (int i = 0; i < mutableMedia.count; i++) {
             dispatch_group_enter(group);
         }
         for (int i = 0; i < mutableMedia.count; i++) {
             UIImageView *currentImage = [UIImageView new];
             NSURL *imageURL = ((InstagramMedia *)mutableMedia[i]).thumbnailURL;
             [loadedMedia addObject:currentImage];
             NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
             [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
             [currentImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                 dispatch_group_leave(group);
                 [loadedMedia[i] setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                 dispatch_group_leave(group);
                 NSLog(@"ERROR: %@", error.localizedDescription);
             }];
         }
         
         dispatch_group_notify(group, dispatch_get_main_queue(), ^{
             //[self.loadedMediaView reloadData];
             completionBlock(nil, [NSArray arrayWithArray:loadedMedia]);
         });
     }
     failure:^(NSError * _Nonnull error, NSInteger serverStatusCode) {
         completionBlock(error, nil);}];
}

@end
