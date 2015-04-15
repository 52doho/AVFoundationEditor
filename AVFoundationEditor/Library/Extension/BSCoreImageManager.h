//
//  BSCoreImageManager.h
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/14/15.
//  Copyright (c) 2015 Zepp US Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BSMultiplyBlendCorner) {
	BSMultiplyBlendCornerNone = 0,
	BSMultiplyBlendCornerTL = 1 << 0,
	BSMultiplyBlendCornerTR = 1 << 1,
	BSMultiplyBlendCornerBR = 1 << 2,
	BSMultiplyBlendCornerBL = 1 << 3,
};

@interface BSCoreImageManager : NSObject

+ (instancetype)sharedManager;

- (UIImage *)blendImageInCorner:(BSMultiplyBlendCorner)corner sizeOfScaleOne:(CGSize)sizeOfScaleOne;

@end
