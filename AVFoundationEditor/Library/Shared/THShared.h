//
//  THShared.h
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 2/9/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#ifndef AVFoundationEditor_THShared_h
#define AVFoundationEditor_THShared_h

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

typedef enum {
	THVideoTrack = 0,
	THTitleTrack,
	THCommentaryTrack,
	THMusicTrack
} THTrack;

#define TRANSITION_DURATION CMTimeMake(1, 1)
static const CGFloat TIMELINE_SCALE_FACTOR = 34.0f;

static inline BOOL THIsEmpty(id value) {
	return value == nil ||
	value == [NSNull null] ||
	([value isKindOfClass:[NSString class]] && [value length] == 0) ||
	([value respondsToSelector:@selector(count)] && [value count] == 0);
}

static inline CGFloat THGetWidthForTimeRange(CMTimeRange timeRange, CGFloat scaleFactor) {
	return CMTimeGetSeconds(timeRange.duration) * scaleFactor;
}

static inline CGPoint THGetOriginForTime(CMTime time) {
	CGFloat seconds = CMTimeGetSeconds(time);
	return CGPointMake(seconds * TIMELINE_SCALE_FACTOR, 0);
}

static inline CMTimeRange THGetTimeRangeForWidth(CGFloat width, CGFloat scaleFactor) {
	CGFloat duration = width / scaleFactor;
	return CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(duration, scaleFactor));
}

static inline CMTime THGetTimeForOrigin(CGFloat origin, CGFloat scaleFactor) {
	CGFloat seconds = origin / scaleFactor;
	return CMTimeMakeWithSeconds(seconds, scaleFactor);
}

#endif
