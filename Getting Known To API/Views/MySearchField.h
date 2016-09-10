//
//  MySearchField.h
//  Getting Known To API
//
//  Created by Михаил Поддубный on 06.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MySearchFieldDelegate <NSObject>

@required

- (void) startSearchWithUsername: (nonnull NSString *) username;

@end

@interface MySearchField : UITextField <UITextFieldDelegate>

@property (nonatomic, weak) id<MySearchFieldDelegate> vcDelegate;

- (instancetype) initWithDelegate: (id<MySearchFieldDelegate>) theDelegate;

@end
