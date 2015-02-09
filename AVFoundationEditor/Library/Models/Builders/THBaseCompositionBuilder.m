//
//  THBaseCompositionBuilder.m
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 2/9/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import "THBaseCompositionBuilder.h"

@implementation THBaseCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
	self = [super init];
	if (self) {
		_timeline = timeline;
		_renderSize = CGSizeMake(1280, 720);
		_frameRate = 30;
	}
	return self;
}

- (id <THComposition>)buildComposition {
	return nil; // over write me
}

@end
