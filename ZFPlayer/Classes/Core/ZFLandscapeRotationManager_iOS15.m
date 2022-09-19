//
//  ZFLandscapeRotationManager_iOS15.m
//  ZFPlayer
//
// Copyright (c) 2020年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFLandscapeRotationManager_iOS15.h"
#import "ZFLandscapeViewController_iOS15.h"

@interface ZFLandscapeRotationManager_iOS15 ()
@property (nonatomic, copy) void(^rotateCompleted)(void);
@property (nonatomic, strong, readonly) ZFLandscapeViewController_iOS15 *landscapeViewController;
/// Force Rotaion, default NO.
@property (nonatomic, assign) BOOL forceRotaion;

@end

@implementation ZFLandscapeRotationManager_iOS15
@synthesize landscapeViewController = _landscapeViewController;

- (ZFLandscapeViewController_iOS15 *)landscapeViewController {
    if (!_landscapeViewController) {
        _landscapeViewController = [[ZFLandscapeViewController_iOS15 alloc] init];
    }
    return _landscapeViewController;
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void(^ __nullable)(void))completion {
    [super interfaceOrientation:orientation completion:completion];
    self.rotateCompleted = completion;
    self.forceRotaion = YES;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)rotationBegin {
    if (self.window.isHidden) {
        self.window.hidden = NO;
        [self.window makeKeyAndVisible];
    }
    [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)rotationEnd {
    if (!self.window.isHidden && !UIInterfaceOrientationIsLandscape(self.currentOrientation)) {
        self.window.hidden = YES;
        [self.containerView.window makeKeyAndVisible];
    }
}

#pragma mark - ZFLandscapeViewControllerDelegate

- (BOOL)ls_shouldAutorotate {
    if (self.allowOrientationRotation || self.forceRotaion) {
        [self rotationBegin];
        return YES;
    }
    return NO;
}

- (void)rotationFullscreenViewController:(ZFLandscapeViewController *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIInterfaceOrientation toOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    UIView *playerSuperview = self.landscapeViewController.playerSuperview;
    if (UIInterfaceOrientationIsLandscape(toOrientation) && self.contentView.superview != playerSuperview) {
        CGRect targetRect = [self.containerView convertRect:self.containerView.bounds toView:self.containerView.window];
        playerSuperview.frame = targetRect;
        self.contentView.frame = playerSuperview.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [playerSuperview addSubview:self.contentView];
        [self.contentView layoutIfNeeded];
    }
    
    if (self.orientationWillChange) self.orientationWillChange(toOrientation);
    if (self.disableAnimations) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            playerSuperview.frame = CGRectMake(0, 0, size.width, size.height);
        } else {
            playerSuperview.frame = [self.containerView convertRect:self.containerView.bounds toView:self.containerView.window];
        }
        [self.contentView layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (self.disableAnimations) {
            [CATransaction commit];
        }
        self.forceRotaion = NO;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (toOrientation == UIInterfaceOrientationPortrait) {
            [self.containerView addSubview:self.contentView];
            self.contentView.frame = self.containerView.bounds;
        } else {
            self.contentView.frame = self.window.bounds;
        }
        [self.contentView layoutIfNeeded];
        [self rotationEnd];
        if (self.orientationDidChanged) self.orientationDidChanged(toOrientation);
        if (self.rotateCompleted) self.rotateCompleted();
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
