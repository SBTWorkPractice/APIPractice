//
//  MyUserModel.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "MyUserModel.h"
#import "InstagramUser.h"

@implementation MyUserModel

- (instancetype) initWithInstagramUser:(InstagramUser *)user {
    self = [super init];
    if (self) {
        self->_username = user.username;
        self->_Id = user.Id;
    }
    return self;
}

@end
