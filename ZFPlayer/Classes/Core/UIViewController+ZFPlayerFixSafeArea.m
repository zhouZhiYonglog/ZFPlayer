//
//  UIViewController+ZFPlayerFixSafeArea.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
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
//  fix: https://github.com/renzifeng/ZFPlayer/issues/1132

#import <objc/message.h>
#import "ZFPlayerNotification.h"
#import "ZFPlayerController.h"

static NSInteger ZFPlayerViewFixSafeAreaTag = 0xFFFFFFF0;

API_AVAILABLE(ios(13.0)) @protocol _UIViewControllerPrivateMethodsProtocol <NSObject>

- (void)_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

@end

@implementation UIViewController (ZFPlayerFixSafeArea)

- (BOOL)zf_containsPlayerView {
    return [self.view viewWithTag:ZFPlayerViewFixSafeAreaTag] != nil;
}

- (void)zf_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    insets.left = 0;
    insets.right = 0;
    BOOL isFullscreen = self.view.bounds.size.width > self.view.bounds.size.height;
    if ( isFullscreen && (insets.top != 0 || [self zf_containsPlayerView] == NO)) {
        [self zf_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
    }
}

@end

/// 需要保证在 ZFPlayerController 中设置 setContainerView: 方法调用之前调用，且不会被当前类的其他 initialize: 方法覆盖
API_AVAILABLE(ios(13.0)) @implementation ZFPlayerNotification (ZFPlayerFixSafeArea)

+ (void)initialize {
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class cls = UIViewController.class;
            SEL originalSelector = @selector(_setContentOverlayInsets:andLeftMargin:rightMargin:);
            SEL swizzledSelector = @selector(zf_setContentOverlayInsets:andLeftMargin:rightMargin:);

            Method originalMethod = class_getInstanceMethod(cls, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);

            Class lc_class = ZFPlayerController.class;
            SEL lc_originalSelector = @selector(setContainerView:);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            SEL lc_swizzledSelector = @selector(zf_setContainerView:);
#pragma clang diagnostic pop
            Method lc_originalMethod = class_getInstanceMethod(lc_class, lc_originalSelector);
            Method lc_swizzledMethod = class_getInstanceMethod(lc_class, lc_swizzledSelector);
            method_exchangeImplementations(lc_originalMethod, lc_swizzledMethod);
        });
    }
}

@end

API_AVAILABLE(ios(13.0)) @implementation ZFPlayerController (ZFPlayerFixSafeArea)

- (void)zf_setContainerView:(UIView *)containerView {
    [self zf_setContainerView:containerView];
    containerView.tag = ZFPlayerViewFixSafeAreaTag;
}

@end

API_AVAILABLE(ios(13.0)) @implementation UINavigationController (ZFPlayerFixSafeArea)

- (BOOL)zf_containsPlayerView {
    return [self.topViewController zf_containsPlayerView];
}

@end

API_AVAILABLE(ios(13.0)) @implementation UITabBarController (ZFPlayerFixSafeArea)

- (BOOL)zf_containsPlayerView {
    UIViewController *vc = self.selectedIndex != NSNotFound ? self.selectedViewController : self.viewControllers.firstObject;
    return [vc zf_containsPlayerView];
}

@end
