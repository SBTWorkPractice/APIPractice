//
//  ServerInteractionManager.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 16.08.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MyUserModel;

@protocol ServerInteractionManagerLoginDelegate <NSObject>

@required

- (void) performLoginWithURL:(NSURL *)url;

@end

@interface ServerInteractionManager : NSObject <UIWebViewDelegate>

+ (void) tryToLogInWithCompletionBlock:(void(^)(BOOL success))completionBlock sender: (UIViewController *) sender;
+ (void ) findAUserWithString:(NSString *)searchString usingCompletionBlock:(void(^)(NSError *error, MyUserModel *targetUser))completionBlock;
+ (void) loadMediaForUser:(MyUserModel *)user withCompletionBlock:(void(^)(NSError *error, NSArray <UIImageView *> *recievedData))completionBlock;

@end
