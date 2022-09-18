//
//  ZFLandscapeRotationManager.m
//  ZFPlayer
//
//  Created by renzifeng on 2022/9/16.
//

#import "ZFLandscapeRotationManager.h"

@interface ZFLandscapeRotationManager ()  <ZFLandscapeViewControllerDelegate>

/// current device orientation observer is activie.
@property (nonatomic, assign) BOOL activeDeviceObserver;

@end

@implementation ZFLandscapeRotationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _supportInterfaceOrientation = ZFInterfaceOrientationMaskAllButUpsideDown;
        _allowOrientationRotation = YES;
        _currentOrientation = UIInterfaceOrientationPortrait;
    }
    return self;
}

- (void)updateRotateView:(ZFPlayerView *)rotateView
           containerView:(UIView *)containerView {
    self.contentView = rotateView;
    self.containerView = containerView;
}

- (UIInterfaceOrientation)getCurrentOrientation {
    if (@available(iOS 16.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *scene = [array firstObject];
        return scene.interfaceOrientation;
    } else {
        return (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    }
}

- (void)handleDeviceOrientationChange {
    if (!self.allowOrientationRotation) return;
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        return;
    }
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;

    // Determine that if the current direction is the same as the direction you want to rotate, do nothing
    if (currentOrientation == _currentOrientation) return;
    _currentOrientation = currentOrientation;
    if (currentOrientation == UIInterfaceOrientationPortraitUpsideDown) return;
    
    switch (currentOrientation) {
        case UIInterfaceOrientationPortrait: {
            if ([self _isSupportedPortrait]) {
                [self rotateToOrientation:UIInterfaceOrientationPortrait animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            if ([self _isSupportedLandscapeLeft]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            if ([self _isSupportedLandscapeRight]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            }
        }
            break;
        default: break;
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void(^ __nullable)(void))completion {}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    [self rotateToOrientation:orientation animated:animated completion:nil];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion {
    _currentOrientation = orientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (!self.window) {
            self.window = [ZFLandscapeWindow new];
            self.landscapeViewController.delegate = self;
            self.window.rootViewController = self.landscapeViewController;
            self.window.rotationManager = self;
        }
    }
    self.disableAnimations = !animated;
    [self interfaceOrientation:orientation completion:^{
        if (completion) completion();
    }];
}

/// is support portrait
- (BOOL)_isSupportedPortrait {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait;
}

/// is support landscapeLeft
- (BOOL)_isSupportedLandscapeLeft {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeLeft;
}

/// is support landscapeRight
- (BOOL)_isSupportedLandscapeRight {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeRight;
}

+ (ZFInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if ([window isKindOfClass:ZFLandscapeWindow.class]) {
        ZFLandscapeRotationManager *manager = ((ZFLandscapeWindow *)window).rotationManager;
        if (manager != nil) {
            return (ZFInterfaceOrientationMask)[manager supportedInterfaceOrientationsForWindow:window];
        }
    }
    return ZFInterfaceOrientationMaskUnknow;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
