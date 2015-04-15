//
//  BSCoreImageManager.m
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/14/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
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

- (NSString *)_getKeyForCorner:(BSMultiplyBlendCorner)corner size:(CGSize)size {
	return [NSString stringWithFormat:@"%i-%@", corner, NSStringFromCGSize(size)];
}

- (UIImage *)blendImageInCorner:(BSMultiplyBlendCorner)corner size:(CGSize)size {
	if (CGSizeEqualToSize(size, CGSizeZero)) {
		return nil;
	}
	
//	size = CGSizeMake(720, 720);
	NSString *key = [self _getKeyForCorner:corner size:size];
	UIImage *image = _dicBlendImagesCache[key];
	if (!image) {
		UIGraphicsBeginImageContextWithOptions(size, NO, 0);
		
		CGFloat halfWidth = size.width / 2;
		CGFloat halfHeight = size.height / 2;
		
		[[UIColor whiteColor] set];
		UIRectFill(CGRectMake(0, 0, size.width, size.height));
		
		[[UIColor colorWithRed:.73 green:.87 blue:.04 alpha:1] set];
		if ((corner | BSMultiplyBlendCornerTL) == BSMultiplyBlendCornerTL) {
			UIRectFill(CGRectMake(0, 0, halfWidth, halfHeight));
		}
		if ((corner | BSMultiplyBlendCornerTR) == BSMultiplyBlendCornerTR) {
			UIRectFill(CGRectMake(halfWidth, 0, halfWidth, halfHeight));
		}
		if ((corner | BSMultiplyBlendCornerBR) == BSMultiplyBlendCornerBR) {
			UIRectFill(CGRectMake(halfWidth, halfHeight, halfWidth, halfHeight));
		}
		if ((corner | BSMultiplyBlendCornerBL) == BSMultiplyBlendCornerBL) {
			UIRectFill(CGRectMake(0, halfHeight, halfWidth, halfHeight));
		}
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		_dicBlendImagesCache[key] = image;
	}
	
	return image;
}

@end
