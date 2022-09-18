//
//  ZFLandscapeRotationManager.h
//  ZFPlayer
//
//  Created by renzifeng on 2022/9/16.
//

#import <Foundation/Foundation.h>
#import "ZFOrientationObserver.h"
#import "ZFLandscapeWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFLandscapeRotationManager : NSObject

/// The block invoked When player will rotate.
@property (nonatomic, copy, nullable) void(^orientationWillChange)(UIInterfaceOrientation orientation);

/// The block invoked when player rotated.
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(UIInterfaceOrientation orientation);

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong, nullable) ZFLandscapeWindow *window;

/// Whether allow the video orientation rotate.
/// default is YES.
@property (nonatomic, assign) BOOL allowOrientationRotation;

@property (nonatomic, assign) BOOL disableAnimations;

/// The support Interface Orientation,default is ZFInterfaceOrientationMaskAllButUpsideDown
@property (nonatomic, assign) ZFInterfaceOrientationMask supportInterfaceOrientation;

/// The current orientation of the player.
/// Default is UIInterfaceOrientationPortrait.
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@property (nonatomic, strong, readonly, nullable) ZFLandscapeViewController *landscapeViewController;

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void(^ __nullable)(void))completion;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

- (UIInterfaceOrientation)getCurrentOrientation;

- (void)handleDeviceOrientationChange;

/// update the rotateView and containerView.
- (void)updateRotateView:(ZFPlayerView *)rotateView
           containerView:(UIView *)containerView;

+ (ZFInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
