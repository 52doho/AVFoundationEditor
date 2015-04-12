//
//  BSIntroduceInView.m
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/12/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import "BSIntroduceInView.h"
#import "CALayer+Geometry.h"

#import <CoreText/CoreText.h>
#import <AVFoundation/AVFoundation.h>

@implementation BSIntroduceInView

@end


@implementation BSIntroduceCompositionLayer

- (id)init {
	self = [super init];
	if (self) {
		_bounds = CGRectMake(0, 0, 720, 720);
	}
	return self;
}

- (CALayer *)layer {
	CALayer *rootLayer = [CALayer layer];
	rootLayer.bounds = _bounds;
	
	CALayer *bgOriginLayer = [self _createLayerWithImage:[UIImage imageNamed:@"Zepp highlight frame.png"]];
	CALayer *bgBlurLayer = [self _createLayerWithImage:[UIImage imageNamed:@"Zepp highlight blur.png"]];
	CALayer *logoLayer = [self _createLayerWithImage:[UIImage imageNamed:@"Zepp TV Icon.png"]];
	CALayer *infoLayer = [self _createInfoLayer];
	
	[rootLayer addSublayer:bgOriginLayer];
	[rootLayer addSublayer:infoLayer];
	[rootLayer addSublayer:bgBlurLayer];
	[rootLayer addSublayer:logoLayer];
	
	static const CGFloat FRAME_RATE = 30;
	CFTimeInterval beginTime = 27/FRAME_RATE;
	
	// Opening
	[bgBlurLayer addAnimation:[self _createScaleAnimationFromScale:1.2 toScale:1 duration:26/FRAME_RATE beginTime:AVCoreAnimationBeginTimeAtZero] forKey:nil];
	[bgBlurLayer addAnimation:[self _createOpacityAnimationFromValue:1 toValue:0 duration:1/FRAME_RATE beginTime:beginTime] forKey:nil];
	
	[logoLayer addAnimation:[self _createScaleAnimationFromScale:1 toScale:1.2 duration:26/FRAME_RATE beginTime:AVCoreAnimationBeginTimeAtZero] forKey:nil];
	[logoLayer addAnimation:[self _createScaleAnimationFromScale:1.3 toScale:3 duration:11/FRAME_RATE beginTime:beginTime] forKey:nil];
	[logoLayer addAnimation:[self _createOpacityAnimationFromValue:1 toValue:0 duration:11/FRAME_RATE beginTime:beginTime] forKey:nil];
	
	[bgOriginLayer addAnimation:[self _createScaleAnimationFromScale:1.2 toScale:1 duration:64/FRAME_RATE beginTime:beginTime] forKey:nil];
	[infoLayer addAnimation:[self _createOpacityAnimationFromValue:0 toValue:1 duration:24/FRAME_RATE beginTime:beginTime] forKey:nil];
	
	beginTime = 91/FRAME_RATE;
	[bgOriginLayer addAnimation:[self _createScaleAnimationFromScale:1 toScale:3 duration:6/FRAME_RATE beginTime:beginTime] forKey:nil];
	[bgOriginLayer addAnimation:[self _createOpacityAnimationFromValue:1 toValue:0 duration:6/FRAME_RATE beginTime:beginTime] forKey:nil];
	[infoLayer addAnimation:[self _createScaleAnimationFromScale:1 toScale:3 duration:6/FRAME_RATE beginTime:beginTime] forKey:nil];
	[infoLayer addAnimation:[self _createOpacityAnimationFromValue:1 toValue:0 duration:6/FRAME_RATE beginTime:beginTime] forKey:nil];
	
	// Closing
	CFTimeInterval duration = 35/FRAME_RATE;
	if (_beginTimeOfClosing == 0) {
		_beginTimeOfClosing = beginTime * 2;
	}
	_beginTimeOfClosing -= duration;
	[bgBlurLayer addAnimation:[self _createScaleAnimationFromScale:1.2 toScale:1 duration:duration beginTime:_beginTimeOfClosing] forKey:nil];
	[bgBlurLayer addAnimation:[self _createOpacityAnimationFromValue:0 toValue:1 duration:duration beginTime:_beginTimeOfClosing] forKey:nil];
	
	[logoLayer addAnimation:[self _createScaleAnimationFromScale:1.2 toScale:1 duration:duration beginTime:_beginTimeOfClosing] forKey:nil];
	[logoLayer addAnimation:[self _createOpacityAnimationFromValue:0 toValue:1 duration:duration beginTime:_beginTimeOfClosing] forKey:nil];
	
	return rootLayer;
}

- (CALayer *)_createLayerWithImage:(UIImage *)image {
	if (!image) {
		return nil;
	}
	
	CALayer *layer = [CALayer layer];
	layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
	layer.position = CGPointMake(CGRectGetMidX(_bounds), CGRectGetMidY(_bounds));
	layer.contents = (id)(image.CGImage);
	layer.contentsGravity = kCAGravityCenter;
	
	return layer;
}

- (CALayer *)_createInfoLayer {
	CALayer *infoLayer = [CALayer layer];
	infoLayer.frame = _bounds;
	
	CALayer *seperatorLayer = [CALayer layer];
	seperatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
	CGFloat width = 350, height = 6;
	seperatorLayer.frame = CGRectMake((_bounds.size.width - width) / 2, (_bounds.size.height - height) / 2, width, height);
	[infoLayer addSublayer:seperatorLayer];
	
	CGFloat padding = 0;
	CATextLayer *titleLayer = [self _createLayerWithText:_title fontSize:200];
	titleLayer.foregroundColor = [UIColor colorWithRed:.816 green:.933 blue:0 alpha:1].CGColor;
	titleLayer.position = CGPointMake(CGRectGetMidX(_bounds), seperatorLayer.top - titleLayer.heightOneHalf - padding);
	[infoLayer addSublayer:titleLayer];
	
	CATextLayer *locationLayer = [self _createLayerWithText:_location fontSize:84];
	locationLayer.position = CGPointMake(CGRectGetMidX(_bounds), seperatorLayer.bottom + locationLayer.heightOneHalf + padding);
	[infoLayer addSublayer:locationLayer];
	
	CATextLayer *teamLayer = [self _createLayerWithText:_team fontSize:84];
	teamLayer.position = CGPointMake(CGRectGetMidX(_bounds), locationLayer.bottom + teamLayer.heightOneHalf + padding);
	[infoLayer addSublayer:teamLayer];
	
	return infoLayer;
}

- (CATextLayer *)_createLayerWithText:(NSString *)text fontSize:(CGFloat)fontSize {
	CATextLayer *textLayer = [CATextLayer layer];
	textLayer.string = text;
	textLayer.fontSize = fontSize;
	
	NSString *fontName = @"Tungsten-Semibold";
	CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
	textLayer.font = fontRef;
	CFRelease(fontRef);
	
	UIFont *font = [UIFont fontWithName:fontName size:fontSize];
	CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: font}];
	textLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
	textLayer.backgroundColor = [UIColor clearColor].CGColor;
	
	return textLayer;
}

- (CABasicAnimation *)_createScaleAnimationFromScale:(CGFloat)fromScale toScale:(CGFloat)toScale duration:(CFTimeInterval)duration beginTime:(CFTimeInterval)beginTime {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	animation.fromValue = @(fromScale);
	animation.toValue = @(toScale);
	animation.duration = duration;
	animation.beginTime = beginTime;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.autoreverses = NO;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	return animation;
}

- (CABasicAnimation *)_createOpacityAnimationFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue duration:(CFTimeInterval)duration beginTime:(CFTimeInterval)beginTime {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = @(fromValue);
	animation.toValue = @(toValue);
	animation.duration = duration;
	animation.beginTime = beginTime;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.autoreverses = NO;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	return animation;
}

@end