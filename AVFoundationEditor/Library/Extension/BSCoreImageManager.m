//
//  BSCoreImageManager.m
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/14/15.
//  Copyright (c) 2015 Zepp US Inc. All rights reserved.
//

#import "BSCoreImageManager.h"

@interface BSCoreImageManager()
{
	NSMutableDictionary *_dicBlendImagesCache;
}

@end

@implementation BSCoreImageManager

static BSCoreImageManager *_instance;
+ (instancetype)sharedManager {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [BSCoreImageManager new];
	});
	return _instance;
}

- (id)init {
	self = [super init];
	if (self) {
		_dicBlendImagesCache = [NSMutableDictionary dictionary];
	}
	return self;
}

- (NSString *)_getKeyForCorner:(BSMultiplyBlendCorner)corner sizeOfScaleOne:(CGSize)sizeOfScaleOne {
	return [NSString stringWithFormat:@"%i-%@", (int)corner, NSStringFromCGSize(sizeOfScaleOne)];
}

- (UIImage *)blendImageInCorner:(BSMultiplyBlendCorner)corner sizeOfScaleOne:(CGSize)sizeOfScaleOne {
	if (CGSizeEqualToSize(sizeOfScaleOne, CGSizeZero)) {
		return nil;
	}
	
	NSString *key = [self _getKeyForCorner:corner sizeOfScaleOne:sizeOfScaleOne];
	UIImage *image = _dicBlendImagesCache[key];
	if (!image) {
		UIGraphicsBeginImageContextWithOptions(sizeOfScaleOne, NO, 1);
		
		CGFloat halfWidth = sizeOfScaleOne.width / 2;
		CGFloat halfHeight = sizeOfScaleOne.height / 2;
		
		[[UIColor whiteColor] set];
		UIRectFill(CGRectMake(0, 0, sizeOfScaleOne.width, sizeOfScaleOne.height));
		
		[[UIColor colorWithRed:.73 green:.87 blue:.04 alpha:1] set];
		if ((corner & BSMultiplyBlendCornerTL) == BSMultiplyBlendCornerTL) {
			UIRectFill(CGRectMake(0, 0, halfWidth, halfHeight));
		}
		if ((corner & BSMultiplyBlendCornerTR) == BSMultiplyBlendCornerTR) {
			UIRectFill(CGRectMake(halfWidth, 0, halfWidth, halfHeight));
		}
		if ((corner & BSMultiplyBlendCornerBR) == BSMultiplyBlendCornerBR) {
			UIRectFill(CGRectMake(halfWidth, halfHeight, halfWidth, halfHeight));
		}
		if ((corner & BSMultiplyBlendCornerBL) == BSMultiplyBlendCornerBL) {
			UIRectFill(CGRectMake(0, halfHeight, halfWidth, halfHeight));
		}
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		_dicBlendImagesCache[key] = image;
	}
	
	return image;
}

@end
