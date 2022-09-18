//
//  ZFLandscapeViewController_iOS15.m
//  ZFPlayer
//
//  Created by 任子丰 on 2022/9/18.
//

#import "ZFLandscapeViewController_iOS15.h"

@implementation ZFLandscapeViewController_iOS15

- (void)viewDidLoad {
    [super viewDidLoad];
    _playerSuperview = [[UIView alloc] initWithFrame:CGRectZero];
    _playerSuperview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_playerSuperview];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return [self.delegate ls_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        return YES;
    }
    return NO;
}

@end
