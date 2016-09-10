//
//  MyUserModel.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InstagramUser;

@interface MyUserModel : NSObject

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *Id;

- (instancetype) initWithInstagramUser: (InstagramUser*) user;

@end
