//
//  THVolumeAutomationView.m
//  Rampy
//
//  Created by Bob McCune on 2/28/13.
//  Copyright (c) 2013 Bob McCune. All rights reserved.
//

#import "THVolumeAutomationView.h"
#import "THVolumeAutomation.h"
#import "THShared.h"

@interface THVolumeAutomationView ()
@property (nonatomic) CGFloat scaleFactor;
@end

@implementation THVolumeAutomationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
	self.backgroundColor = [UIColor clearColor];
}

- (void)setAudioRamps:(NSArray *)audioRamps {
	_audioRamps = audioRamps;
	[self setNeedsDisplay];
}

- (CGFloat)xForTime:(CMTime)time {
	CMTime xTime = CMTimeSubtract(self.duration, CMTimeSubtract(self.duration, time));
	CGFloat seconds = 0;
	if (CMTIME_COMPARE_INLINE(xTime, !=, kCMTimeInvalid)) {
		seconds = CMTimeGetSeconds(xTime);
	}
	return seconds * self.scaleFactor;
}

- (void)setDuration:(CMTime)duration {
	_duration = duration;
	self.scaleFactor = self.bounds.size.width / CMTimeGetSeconds(duration);
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Flip context to think in more natural volume adjustment orientation
	CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(rect));
	CGContextScaleCTM(context, 1.0, -1.0);

	CGFloat x = 0.0f, y = 0.0f;
	CGFloat rectHeight = CGRectGetHeight(rect);
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y);

	// Build points for volume ramps
	for (THVolumeAutomation *automation in self.audioRamps) {
		x = [self xForTime:automation.timeRange.start];
		y = automation.startVolume * rectHeight;
		CGPathAddLineToPoint(path, NULL, x, y);

		x = x + THGetWidthForTimeRange(automation.timeRange, self.scaleFactor);
		y = automation.endVolume * rectHeight;
		CGPathAddLineToPoint(path, NULL, x, y);
	}
	
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.000 alpha:0.750].CGColor);
	CGContextAddPath(context, path);
	CGContextDrawPath(context, kCGPathFill);

	CGPathRelease(path);
}


@end
