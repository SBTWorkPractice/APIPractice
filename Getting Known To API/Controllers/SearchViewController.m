//
//  SearchViewController.m
//  Getting Known To API
//
//  Created by Михаил Поддубный on 02.09.16.
//  Copyright © 2016 Михаил Поддубный. All rights reserved.
//

#import "SearchViewController.h"
#import "MyButtons.h"
#import "MySearchField.h"

@interface SearchViewController () <MyButtonDelegate, MySearchFieldDelegate>

@property (nonatomic, strong) MySearchField *searchField;

@end

@implementation SearchViewController

- (instancetype) initWithDelegate:(id<SearchViewControllerDelegate>)theDelegate {
    self = [super init];
    if (self) {
        self.delegate = theDelegate;
    }
    return self;
}

- (void) viewWillLayoutSubviews {
        self.searchField.frame = CGRectMake(20, (self.view.frame.size.height - 100) / 2, self.view.frame.size.width - 40, 40);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.searchField = [[MySearchField alloc] initWithDelegate:self];
    [self.view addSubview:self.searchField];
}

- (void) startSearchWithUsername:(NSString *)username {
    if ([self.delegate respondsToSelector:@selector(startSearchForUser:)]) {
        [self.delegate startSearchForUser:username];
    }
}

//- (void) startSearch {
//    khgykiyc
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
