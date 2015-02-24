//
//  LVNavigationController.m
//  LVNavibarViewController
//
//  Created by lvpw on 15/2/18.
//  Copyright (c) 2015年 lvpw. All rights reserved.
//

#import "LVNavigationController.h"

static CGFloat LVNavigationAnimationDuration = 0.25;

@interface LVNavigationController () <UIGestureRecognizerDelegate> {
    CGFloat oldX;   // 记录手势开始时的位置
    CGPoint currentViewCenter, toViewCenter, shadowImageViewCenter;
    BOOL gestureRecognizerBacking;
    CGRect frame;
}

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readonly) UIViewController *toViewController;
@property (nonatomic, weak) UIImageView *shadowImageView;

@end

@implementation LVNavigationController

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        gestureRecognizerBacking = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO; // forbidden the origin recognizer
    }
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    _panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

#pragma mark - over ride

- (UIViewController *)toViewController {
    if (self.viewControllers.count > 1) {
        return self.viewControllers[self.viewControllers.count - 2];
    } else {
        return nil;
    }
}

/**
 *  以下两个override方法不必管理旋转的生命周期
 */
- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    if (!gestureRecognizerBacking) {
//        NSLog(@"shouldAutomaticallyForwardAppearanceMethods - YES");
        return YES;
    }
//    NSLog(@"shouldAutomaticallyForwardAppearanceMethods - NO");
    return NO;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    if (!gestureRecognizerBacking) {
        return YES;
    }
    return NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 判断方向
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [recognizer velocityInView:recognizer.view];
        if (point.x <= 0) {
            return NO;
        }
    }
    // 判断当前栈中数量
    if (self.viewControllers.count > 1) {
        return YES;
    }
    return NO;
}

#pragma mark - Action

- (void)panAction:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan: {
            oldX = [recognizer locationInView:self.view].x;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            float deltaX = [recognizer locationInView:self.view].x - oldX;
            if (!gestureRecognizerBacking) {
                if (deltaX <= 0) return;
                gestureRecognizerBacking = YES;
                [self.topViewController beginAppearanceTransition:NO animated:YES];
                
                self.toViewController.view.frame = [self startFrame];
                // ??? 取的superview是否合适
                [[self.topViewController.view superview] insertSubview:self.toViewController.view belowSubview:self.topViewController.view];
                [self.toViewController beginAppearanceTransition:YES animated:YES];
                UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-9, 0, 9, [UIScreen mainScreen].bounds.size.height)];
                shadowImageView.image = [UIImage imageNamed:@"navibar_shadow"];
                [[self.topViewController.view superview] insertSubview:shadowImageView aboveSubview:self.toViewController.view];
                self.shadowImageView = shadowImageView;
                
                currentViewCenter = self.topViewController.view.center;
                toViewCenter = self.toViewController.view.center;
                shadowImageViewCenter = shadowImageView.center;
            }
            self.topViewController.view.center = CGPointMake(currentViewCenter.x + deltaX, currentViewCenter.y);
            self.toViewController.view.center = CGPointMake(toViewCenter.x + deltaX * (95 / 320.f), toViewCenter.y);
            self.shadowImageView.center = CGPointMake(shadowImageViewCenter.x + deltaX, shadowImageViewCenter.y);
            self.shadowImageView.alpha = 1.0f - (self.shadowImageView.frame.origin.x + 9) / [UIScreen mainScreen].bounds.size.width;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            CGFloat centerX = self.topViewController.view.center.x;
            CGPoint point = [recognizer velocityInView:recognizer.view];
            if ((point.x > 50) || centerX > self.view.bounds.size.width) {
                [UIView animateWithDuration:LVNavigationAnimationDuration animations:^{
                    self.toViewController.view.frame = [UIScreen mainScreen].bounds;
                    self.topViewController.view.frame = [self endFrame];
                    self.shadowImageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 9, 0, 9, [UIScreen mainScreen].bounds.size.height);
                    self.shadowImageView.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.shadowImageView removeFromSuperview];
                    
                    [self popViewControllerAnimated:NO];
                    
                    gestureRecognizerBacking = NO;
                }];
            } else {
                [self.toViewController beginAppearanceTransition:NO animated:YES];
                [self.topViewController beginAppearanceTransition:YES animated:YES];
                [UIView animateWithDuration:LVNavigationAnimationDuration animations:^{
                    self.topViewController.view.frame = self.view.bounds;
                    self.toViewController.view.frame = [self startFrame];
                    self.shadowImageView.frame = CGRectMake(-9, 0, 9, [UIScreen mainScreen].bounds.size.height);
                    self.shadowImageView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [self.shadowImageView removeFromSuperview];
                    [self.toViewController.view removeFromSuperview];
                    [self.toViewController endAppearanceTransition];
                    [self.topViewController endAppearanceTransition];
                    
                    gestureRecognizerBacking = NO;
                }];
            }
        }
            break;
    }
}

#pragma mark - Util

- (CGRect)startFrame {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect startFrame;
    startFrame = CGRectMake(-95 / 320.f * width, 0, width, height);
    return startFrame;
}

- (CGRect)endFrame {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect endFrame;
    endFrame = CGRectMake(width, 0, width, height);
    return endFrame;
}

@end
