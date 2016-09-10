//
//  MySearchField.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "MySearchField.h"

@implementation MySearchField

- (instancetype) initWithDelegate: (id<MySearchFieldDelegate>) theDelegate {
    self = [super init];
    if (self) {
        self.vcDelegate = theDelegate;
        [self setup];
    }
    return self;
}

- (void) setup {
    self.delegate = self;
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setBackgroundColor: [UIColor colorWithWhite:0.0 alpha:0.2]];
    [self setPlaceholder:@"Enter a username to search"];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self resignFirstResponder];
    [self usernameIsEntered];
    return YES;
}

- (void) usernameIsEntered {
    if ([self.vcDelegate respondsToSelector:@selector(startSearchWithUsername:)]) {
        [self.vcDelegate startSearchWithUsername: self.text];
    }
}

@end
