//
//  MIT License
//
//  Copyright (c) 2013 Bob McCune http://bobmccune.com/
//  Copyright (c) 2013 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//

#import "THAdvancedCompositionBuilder.h"
#import "AVPlayerItem+THAdditions.h"
#import "THVideoItem.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THTitleLayer.h"
#import "THAdvancedComposition.h"
#import "THTransitionInstructions.h"

@interface THAdvancedCompositionBuilder ()
@property (nonatomic, strong) THTimeline *timeline;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVVideoComposition *videoComposition;
@property (nonatomic, weak) AVMutableCompositionTrack *musicTrack;
@end

@implementation THAdvancedCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
	self = [super init];
	if (self) {
		_timeline = timeline;
	}
	return self;
}

- (id <THComposition>)buildComposition {

	self.composition = [AVMutableComposition composition];

	[self buildCompositionTracks];

	return [[THAdvancedComposition alloc] initWithComposition:self.composition
											 videoComposition:[self buildVideoComposition]
													 audioMix:[self buildAudioMix]
												   titleLayer:[self buildTitleLayer]];
}

- (void)buildCompositionTracks {

	AVMutableCompositionTrack *compositionTrackA = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
																				 preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack *compositionTrackB = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
																				 preferredTrackID:kCMPersistentTrackID_Invalid];

	NSArray *tracks = @[compositionTrackA, compositionTrackB];

	CMTime cursorTime = kCMTimeZero;

	CMTime transitionDuration = self.timeline.transitions.count > 0 ? TRANSITION_DURATION : kCMTimeZero;
	NSUInteger videoCount = self.timeline.videos.count;

	// Insert video segments into alternating tracks.  Overlap them by the transition duration.
	for (NSUInteger i = 0; i < videoCount; i++) {

		NSUInteger trackIndex = i % 2;

		THMediaItem *item = self.timeline.videos[i];
		AVMutableCompositionTrack *currentTrack = tracks[trackIndex];
		AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:AVMediaTypeVideo][0];
		[currentTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];

		// Overlap clips by transition duration by moving cursor to the current
		// item's duration and then back it up by the transition duration time.
		cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
		cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
	}

	// Add voice overs
	[self addCompositionTrackOfType:AVMediaTypeAudio forMediaItems:self.timeline.voiceOvers maxCursorTime:cursorTime];

	// Add music track
	self.musicTrack = [self addCompositionTrackOfType:AVMediaTypeAudio forMediaItems:self.timeline.musicItems maxCursorTime:cursorTime];
}

- (AVMutableCompositionTrack *)addCompositionTrackOfType:(NSString *)mediaType forMediaItems:(NSArray *)mediaItems maxCursorTime:(CMTime)maxCursorTime {

	AVMutableCompositionTrack *compositionTrack = nil;

	if (!THIsEmpty(mediaItems)) {
		compositionTrack = [self.composition addMutableTrackWithMediaType:mediaType preferredTrackID:kCMPersistentTrackID_Invalid];

		CMTime cursorTime = kCMTimeZero;

		for (THMediaItem *item in mediaItems) {

			if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
				cursorTime = item.startTimeInTimeline;
			}

			BOOL needStop = NO;
			CMTime nextCursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
			if (CMTIME_COMPARE_INLINE(nextCursorTime, >, maxCursorTime)) {
				CMTime duration = CMTimeSubtract(maxCursorTime, item.timeRange.start);
				item.timeRange = CMTimeRangeMake(item.timeRange.start, duration);
				needStop = YES;
			}
			AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType][0];
			[compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];

			// Move cursor to next item time
			cursorTime = nextCursorTime;
			
			if (needStop) {
				break;
			}
		}
	}

	return compositionTrack;
}

- (AVVideoComposition *)buildVideoComposition {
	// Create the video composition using the magic method in iOS 6.
	AVMutableVideoComposition *composition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
	NSArray *transitionInstructions = [self transitionInstructionsInVideoComposition:composition];
	for (THTransitionInstructions *instructions in transitionInstructions) {

		CMTimeRange timeRange = instructions.compositionInstruction.timeRange;
		AVMutableVideoCompositionLayerInstruction *fromLayerInstruction = instructions.fromLayerInstruction;
		AVMutableVideoCompositionLayerInstruction *toLayerInstruction = instructions.toLayerInstruction;

		if (instructions.transition.type == THVideoTransitionTypeDissolve) {
			// Cross Disolve
			[fromLayerInstruction setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:timeRange];

		} else if (instructions.transition.type == THVideoTransitionTypePush) {
			// Push
			// Set a transform ramp on fromLayer from identity to all the way left of the screen.
			[fromLayerInstruction setTransformRampFromStartTransform:CGAffineTransformIdentity
													  toEndTransform:CGAffineTransformMakeTranslation(-OUTPUT_VIDEO_SIZE.width, 0.0)
														   timeRange:timeRange];
			// Set a transform ramp on toLayer from all the way right of the screen to identity.
			[toLayerInstruction setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(OUTPUT_VIDEO_SIZE.width, 0.0)
													toEndTransform:CGAffineTransformIdentity
														 timeRange:timeRange];

		}

		instructions.compositionInstruction.layerInstructions = @[fromLayerInstruction, toLayerInstruction];
	}
	composition.renderSize = OUTPUT_VIDEO_SIZE;
	composition.frameDuration = CMTimeMake(1, OUTPUT_FRAME_RATE);
	
	return composition;
}

// Extract the composition and layer instructions out of the prebuilt AVVideoComposition.
// Make the association between the instructions and the THVideoTransition the user configured
// in the timeline.  There is plenty of room for improvement in how I'm doing this.
- (NSArray *)transitionInstructionsInVideoComposition:(AVVideoComposition *)videoComposition {
	NSMutableArray *instructions = [NSMutableArray array];
	int layerInstructionIndex = 1;
	BOOL hasVideoTransition = (videoComposition.instructions.count == (self.timeline.videos.count * 2 - 1));
	for (AVMutableVideoCompositionInstruction *instruction in videoComposition.instructions) {
		if (instruction.layerInstructions.count == 2) {

			THTransitionInstructions *transitionInstructions = [[THTransitionInstructions alloc] init];
			transitionInstructions.compositionInstruction = instruction;
			transitionInstructions.fromLayerInstruction = instruction.layerInstructions[1 - layerInstructionIndex];
			transitionInstructions.toLayerInstruction = instruction.layerInstructions[layerInstructionIndex];

			[instructions addObject:transitionInstructions];

			layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
		}
		
		// update transform
		int videoItemIndex = [videoComposition.instructions indexOfObject:instruction];
		if (hasVideoTransition) {
			videoItemIndex = (videoItemIndex + 1) / 2;
		}
		if (videoItemIndex < self.timeline.videos.count) {
			THMediaItem *item = self.timeline.videos[videoItemIndex];
			AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:AVMediaTypeVideo][0];
			CGSize size = assetTrack.naturalSize;
			CGAffineTransform transform = [self _calculateTransformWithSize:size inSize:OUTPUT_VIDEO_SIZE];
			
			for (AVMutableVideoCompositionLayerInstruction *compositionLayerInstruction in instruction.layerInstructions) {
				CGAffineTransform targetTransform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
				[compositionLayerInstruction setTransform:targetTransform atTime:instruction.timeRange.start];
			}
		}
	}

	NSArray *transitions = self.timeline.transitions;

	// Transitions are disabled
	if (THIsEmpty(transitions)) {
		return instructions;
	}
	
	NSAssert(instructions.count == transitions.count, @"Instruction count and transition count do not match.");

	for (int i = 0; i < instructions.count; i++) {
		THTransitionInstructions *transitionInstructions = instructions[i];
		transitionInstructions.transition = self.timeline.transitions[i];
	}
	return instructions;
}

- (CGAffineTransform)_calculateTransformWithSize:(CGSize)size inSize:(CGSize)inSize {
	CGFloat scaleX = inSize.width / size.width;
	CGFloat scaleY = inSize.height / size.height;
	CGFloat scale = MAX(scaleX, scaleY);
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((inSize.width - width) / 2.0f);
	float dheight = ((inSize.height - height) / 2.0f);
	
	CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
	transform = CGAffineTransformTranslate(transform, dwidth, dheight);
	
	return transform;
}

- (AVAudioMix *)buildAudioMix {
	NSArray *items = self.timeline.musicItems;
	// Only one allowed
	if (items.count == 1) {
		THAudioItem *item = self.timeline.musicItems[0];

		AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
		AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.musicTrack];
		for (THVolumeAutomation *automation in item.volumeAutomation) {
			[parameters setVolumeRampFromStartVolume:automation.startVolume
			                             toEndVolume:automation.endVolume
					                       timeRange:automation.timeRange];
		}
		audioMix.inputParameters = @[parameters];
		return audioMix;
	}
	return nil;
}

- (CALayer *)buildTitleLayer {

	CALayer *titleLayer = [CALayer layer];
	titleLayer.bounds = OUTPUT_VIDEO_BOUNDS;
	titleLayer.position = CGPointMake(OUTPUT_VIDEO_SIZE.width / 2, OUTPUT_VIDEO_SIZE.height / 2);

	for (THCompositionLayer *compositionLayer in self.timeline.titles) {
		CALayer *layer = compositionLayer.layer;
		layer.position = CGPointMake(CGRectGetMidX(titleLayer.bounds), CGRectGetMidY(titleLayer.bounds));
		[titleLayer addSublayer:layer];
	}
	return titleLayer;
}

@end
