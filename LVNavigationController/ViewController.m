//
//  ViewController.m
//  LVNavibarViewController
//
//  Created by lvpw on 15/2/18.
//  Copyright (c) 2015年 lvpw. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self log:@"viewDidLoad"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self log:@"viewWillAppear"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self log:@"viewDidAppear"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self log:@"viewWillDisappear"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self log:@"viewDidDisappear"];
}

#pragma mark - Util

- (void)log:(NSString *)logs {
    self.textView.text = [self.textView.text stringByAppendingFormat:@"%@ - %@\n", self.identifier, logs];
}

@end
