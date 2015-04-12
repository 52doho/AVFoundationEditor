//
//  CALayer+Geometry.h
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/12/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Geometry)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic, readonly) CGFloat widthOneHalf;
@property (nonatomic) CGFloat height;
@property (nonatomic, readonly) CGFloat heightOneHalf;

@end
