//
//  BSCustomVideoCompositor.m
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/14/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import "BSCustomVideoCompositor.h"
#import "BSCoreImageManager.h"

#import <CoreImage/CoreImage.h>

// Ref: AVCustomEdit from Apple

typedef NSArray * (^BSFilterBlock)(CGSize frameSize);

@interface BSCustomVideoCompositor()
{
	BOOL								_shouldCancelAllRequests;
	dispatch_queue_t					_renderingQueue;
	dispatch_queue_t					_renderContextQueue;
	AVVideoCompositionRenderContext*	_renderContext;
	
	CIContext *ciContext;
	
	NSMutableDictionary *_filters;
	CIFilter *_grayFilter;
	CIFilter *_transformFilter;
	CIFilter *_pureColorFilter;
	CIFilter *_multiplyBlendCornerFilter;
	int _indexOfCurrentFrame, _indexOfLastFilterFrame;
}

@end


@implementation BSCustomVideoCompositor

- (id)init
{
	self = [super init];
	if (self)
	{
		_renderingQueue = dispatch_queue_create("com.apple.aplcustomvideocompositor.renderingqueue", DISPATCH_QUEUE_SERIAL);
		_renderContextQueue = dispatch_queue_create("com.apple.aplcustomvideocompositor.rendercontextqueue", DISPATCH_QUEUE_SERIAL);

		_indexOfCurrentFrame = 0;
		
		ciContext = [CIContext contextWithOptions:nil];
		[self _setupFilters];
	}
	return self;
}

- (NSValue *)_transformToValue:(CGAffineTransform)transform {
	return [NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)];
}

- (void)_setBlendFilterWithCorner:(BSMultiplyBlendCorner)corner size:(CGSize)size {
	UIImage *image = [[BSCoreImageManager sharedManager] blendImageInCorner:corner size:size];
	[_multiplyBlendCornerFilter setValue:[CIImage imageWithCGImage:image.CGImage] forKey:@"inputBackgroundImage"];
}

- (void)_setupFilters {
	_grayFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:@"inputBrightness", @(0), @"inputContrast", @(1.1), @"inputSaturation", @(0), nil];
//	_grayFilter = [CIFilter filterWithName:@"CISepiaTone"];           // 3
//	[_grayFilter setValue:@0.8f forKey:kCIInputIntensityKey];
	
	_transformFilter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:@"inputTransform", [self _transformToValue:CGAffineTransformMakeScale(1.2, 1.2)], nil];
	
	_pureColorFilter = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:@"inputColor", [CIColor colorWithRed:.78 green:.94 blue:.04 alpha:1], nil];
	
	_multiplyBlendCornerFilter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
	
	_filters = [NSMutableDictionary dictionary];
	BSFilterBlock pureColorFilterBlock = ^NSArray * (CGSize frameSize){
		return @[_pureColorFilter];
	};
	BSFilterBlock composeFilterBlock_Gray = ^NSArray * (CGSize frameSize){
		return @[_grayFilter];
	};
	BSFilterBlock composeFilterBlock_Gray_Transform = ^NSArray * (CGSize frameSize){
		return @[_transformFilter, _grayFilter];
	};
	BSFilterBlock composeFilterBlock_Gray_Transform_Big = ^NSArray * (CGSize frameSize){
		[_transformFilter setValue:[self _transformToValue:CGAffineTransformMakeScale(1.4, 1.4)] forKey:@"inputTransform"];
		return @[_transformFilter, _grayFilter];
	};
	
	BSFilterBlock composeFilterBlock_TL = ^NSArray * (CGSize frameSize){
		[self _setBlendFilterWithCorner:BSMultiplyBlendCornerTL size:frameSize];
		return @[_transformFilter, _grayFilter, _multiplyBlendCornerFilter];
	};
	BSFilterBlock composeFilterBlock_TR = ^NSArray * (CGSize frameSize){
		[self _setBlendFilterWithCorner:BSMultiplyBlendCornerTR size:frameSize];
		return @[_transformFilter, _grayFilter, _multiplyBlendCornerFilter];
	};
	BSFilterBlock composeFilterBlock_BL = ^NSArray * (CGSize frameSize){
		[self _setBlendFilterWithCorner:BSMultiplyBlendCornerBL size:frameSize];
		return @[_transformFilter, _grayFilter, _multiplyBlendCornerFilter];
	};
	BSFilterBlock composeFilterBlock_BR = ^NSArray * (CGSize frameSize){
		[self _setBlendFilterWithCorner:BSMultiplyBlendCornerBR size:frameSize];
		return @[_transformFilter, _grayFilter, _multiplyBlendCornerFilter];
	};
	BSFilterBlock composeFilterBlock_TL_BR = ^NSArray * (CGSize frameSize){
		[self _setBlendFilterWithCorner:BSMultiplyBlendCornerTL | BSMultiplyBlendCornerBR size:frameSize];
		return @[_transformFilter, _grayFilter, _multiplyBlendCornerFilter];
	};
	BSFilterBlock composeFilterBlock_BL_TR = ^NSArray * (CGSize frameSize){
		[self _setBlendFilterWithCorner:BSMultiplyBlendCornerBL | BSMultiplyBlendCornerTR size:frameSize];
		return @[_transformFilter, _grayFilter, _multiplyBlendCornerFilter];
	};
	
	_filters[@(0)] = composeFilterBlock_TL;
	_filters[@(1)] = composeFilterBlock_TR;
	_filters[@(2)] = composeFilterBlock_BL;
	_filters[@(3)] = composeFilterBlock_BR;
	
	
	_filters[@(12)] = pureColorFilterBlock;
	_filters[@(13)] = pureColorFilterBlock;
	_filters[@(16)] = pureColorFilterBlock;
	_filters[@(17)] = pureColorFilterBlock;
	
	_filters[@(78)] = composeFilterBlock_TL;
	_filters[@(79)] = composeFilterBlock_TL;
	_filters[@(80)] = composeFilterBlock_Gray_Transform;
	_filters[@(81)] = composeFilterBlock_Gray_Transform;
	_filters[@(82)] = composeFilterBlock_TR;
	_filters[@(83)] = composeFilterBlock_TR;
	_filters[@(84)] = composeFilterBlock_Gray_Transform;
	_filters[@(85)] = composeFilterBlock_Gray_Transform;
	_filters[@(86)] = composeFilterBlock_BL;
	_filters[@(87)] = composeFilterBlock_BL;
	_filters[@(88)] = composeFilterBlock_Gray_Transform;
	_filters[@(89)] = composeFilterBlock_Gray_Transform;
	_filters[@(90)] = composeFilterBlock_BR;
	_filters[@(91)] = composeFilterBlock_BR;
	
	_filters[@(180)] = composeFilterBlock_TR;
	_filters[@(181)] = composeFilterBlock_TR;
	_filters[@(182)] = composeFilterBlock_TR;
	_filters[@(183)] = composeFilterBlock_BR;
	_filters[@(184)] = composeFilterBlock_BR;
	_filters[@(185)] = composeFilterBlock_BR;
	_filters[@(186)] = composeFilterBlock_TL_BR;
	_filters[@(187)] = composeFilterBlock_TL_BR;
	_filters[@(188)] = composeFilterBlock_TL_BR;
	
	_filters[@(189)] = pureColorFilterBlock;
	_filters[@(190)] = pureColorFilterBlock;
	_filters[@(191)] = composeFilterBlock_BL_TR;
	_filters[@(192)] = composeFilterBlock_BL_TR;
	_filters[@(193)] = pureColorFilterBlock;
	_filters[@(194)] = pureColorFilterBlock;
	_filters[@(195)] = composeFilterBlock_BL_TR;
	_filters[@(196)] = composeFilterBlock_BL_TR;
	_filters[@(197)] = pureColorFilterBlock;
	_filters[@(198)] = pureColorFilterBlock;
	
	_filters[@(199)] = composeFilterBlock_Gray_Transform;
	_filters[@(200)] = composeFilterBlock_Gray_Transform;
	_filters[@(201)] = composeFilterBlock_Gray_Transform;
	_filters[@(202)] = composeFilterBlock_Gray_Transform;
	_filters[@(203)] = composeFilterBlock_Gray_Transform;
	_filters[@(204)] = composeFilterBlock_Gray_Transform;
	_filters[@(205)] = composeFilterBlock_Gray_Transform;
	_filters[@(206)] = composeFilterBlock_Gray_Transform;
	_filters[@(207)] = composeFilterBlock_Gray_Transform;
	_filters[@(208)] = composeFilterBlock_Gray_Transform;
	_filters[@(209)] = composeFilterBlock_Gray_Transform;
	_filters[@(210)] = composeFilterBlock_Gray_Transform;
	_filters[@(211)] = composeFilterBlock_Gray_Transform;
	_filters[@(212)] = composeFilterBlock_Gray_Transform;
	
	_filters[@(213)] = composeFilterBlock_BL;
	_filters[@(214)] = composeFilterBlock_BL;
	_filters[@(215)] = composeFilterBlock_Gray_Transform;
	_filters[@(216)] = composeFilterBlock_BR;
	_filters[@(217)] = composeFilterBlock_BR;
	_filters[@(218)] = composeFilterBlock_Gray_Transform;
	_filters[@(219)] = composeFilterBlock_TL;
	_filters[@(220)] = composeFilterBlock_TL;
	_filters[@(221)] = composeFilterBlock_Gray_Transform;
	_filters[@(222)] = composeFilterBlock_TR;
	_filters[@(223)] = composeFilterBlock_TR;
	
	_filters[@(263)] = composeFilterBlock_Gray_Transform_Big;
	_filters[@(264)] = composeFilterBlock_Gray_Transform_Big;
	_filters[@(273)] = composeFilterBlock_Gray_Transform_Big;
	_filters[@(274)] = composeFilterBlock_Gray_Transform_Big;
	
	_filters[@(304)] = pureColorFilterBlock;
	_filters[@(305)] = pureColorFilterBlock;
	_filters[@(308)] = pureColorFilterBlock;
	_filters[@(309)] = pureColorFilterBlock;
	
	_indexOfLastFilterFrame = 310;
	_filters[@(_indexOfLastFilterFrame)] = composeFilterBlock_Gray;
}

- (NSDictionary *)sourcePixelBufferAttributes
{
	return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
			  (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext
{
	return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
			  (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext
{
	dispatch_sync(_renderContextQueue, ^() {
		_renderContext = newRenderContext;
	});
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request
{
	@autoreleasepool {
		dispatch_async(_renderingQueue,^() {
			// Check if all pending requests have been cancelled
			if (_shouldCancelAllRequests) {
				[request finishCancelledRequest];
			} else {
				CMPersistentTrackID trackID = [[request.sourceTrackIDs firstObject] intValue];
				CVPixelBufferRef sourceBuffer = [request sourceFrameByTrackID:trackID];
				int bufferHeight = (int)CVPixelBufferGetHeight(sourceBuffer);
				int bufferWidth = (int)CVPixelBufferGetWidth(sourceBuffer);
				
				BSFilterBlock block;
				if (_indexOfCurrentFrame > _indexOfLastFilterFrame) {
					block = _filters[@(_indexOfLastFilterFrame)];
				} else {
					block = _filters[@(_indexOfCurrentFrame)];
				}
				_indexOfCurrentFrame++;
				
				NSArray *filters = block ? block(CGSizeMake(bufferWidth, bufferHeight)) : nil;
				if (filters) {
					CIImage *filteredImage = [CIImage imageWithCVPixelBuffer:sourceBuffer];
					for (CIFilter *filter in filters) {
						if (![filter.name isEqualToString:@"CIConstantColorGenerator"]) {
							[filter setValue:filteredImage forKey:kCIInputImageKey];
						}
						filteredImage = [filter valueForKey:kCIOutputImageKey];
					}
					
					CVPixelBufferRef filteredPixels = [_renderContext newPixelBuffer];
					[ciContext render:filteredImage toCVPixelBuffer:filteredPixels];
					
					bufferHeight = (int)CVPixelBufferGetHeight(filteredPixels);
					bufferWidth = (int)CVPixelBufferGetWidth(filteredPixels);
					CGRect extent = filteredImage.extent;
					
					if (filteredPixels) {
						[request finishWithComposedVideoFrame:filteredPixels];
						CFRelease(filteredPixels);
					} else {
						[request finishWithError:nil];
					}
				} else {
					if (sourceBuffer) {
						[request finishWithComposedVideoFrame:sourceBuffer];
					} else {
						[request finishWithError:nil];
					}
				}
			}
		});
	}
}

- (void)cancelAllPendingVideoCompositionRequests
{
	// pending requests will call finishCancelledRequest, those already rendering will call finishWithComposedVideoFrame
	_shouldCancelAllRequests = YES;
	
	dispatch_barrier_async(_renderingQueue, ^() {
		// start accepting requests again
		_shouldCancelAllRequests = NO;
	});
}

@end
