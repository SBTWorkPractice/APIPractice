//
//  ServerInteractionManager.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 16.08.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "ServerInteractionManager.h"
#import "InstagramKit.h"
#import "MyMediaModel.h"
#import "MyUserModel.h"
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
    [engine logout];
    NSURL *authURL = [engine authorizationURLForScope:InstagramKitLoginScopePublicContent];
    [sender presentViewController:loginVC animated:YES completion:nil];
    if ([loginVC respondsToSelector:@selector(performLoginWithURL:)]) {
        [loginVC performLoginWithURL:authURL];
    }
}

+ (void ) findAUserWithString:(NSString *)searchString usingCompletionBlock:(void(^)(NSError *error, MyUserModel *targetUser))completionBlock {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    MyUserModel * __block __strong targetUser;
    [engine searchUsersWithString:searchString withSuccess:^(NSArray<InstagramUser *> *users, InstagramPaginationInfo *paginationInfo) {
        targetUser = [[MyUserModel alloc] initWithInstagramUser:users[0]];
        completionBlock(nil, targetUser);
    } failure:^(NSError * _Nonnull error, NSInteger serverStatusCode) {
        completionBlock(error, nil);
    }];
}

+ (void) loadMediaForUser:(MyUserModel *)user withCompletionBlock:(void(^)(NSError *error, NSArray <UIImageView *> *recievedData))completionBlock {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    __block NSMutableArray <UIImageView *> *loadedMedia;
    [engine
     getMediaForUser:user.Id
     withSuccess:^(NSArray <InstagramMedia *> *media, InstagramPaginationInfo *paginationInfo) {
         NSMutableArray <MyMediaModel *> *mutableMedia = [NSMutableArray arrayWithCapacity:0];
         for (int i = 0; i < media.count; i++) {
             MyMediaModel *mediaModel = [[MyMediaModel alloc] initWithMedia:media[i]];
             [mutableMedia addObject: mediaModel];
         }
         BOOL isSorted = NO;
         MyMediaModel *mediaBuffer;
         for (int i = 0; i < mutableMedia.count; i++) {
             while (mutableMedia[i].isVideo == YES) {
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
         loadedMedia = [NSMutableArray arrayWithCapacity:mutableMedia.count];
         dispatch_group_t group = dispatch_group_create();
         for (int i = 0; i < mutableMedia.count; i++) {
             dispatch_group_enter(group);
         }
         for (int i = 0; i < mutableMedia.count; i++) {
             UIImageView *currentImage = [UIImageView new];
             NSURL *imageURL = ((MyMediaModel *)mutableMedia[i]).thumbnailURL;
             [loadedMedia addObject:currentImage];
             NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
             [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
             [currentImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                 dispatch_group_leave(group);
                 [loadedMedia[i] setImage:image];
             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                 dispatch_group_leave(group);
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [alert show];
             }];
         }
         
         dispatch_group_notify(group, dispatch_get_main_queue(), ^{
             completionBlock(nil, [NSArray arrayWithArray:loadedMedia]);
         });
     }
     failure:^(NSError * _Nonnull error, NSInteger serverStatusCode) {
         completionBlock(error, nil);}];
}

@end
