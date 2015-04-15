//
//  AVMutableVideoCompositionLayerInstruction+THAdditions.m
//  AVFoundationEditor
//
//  Created by Gary Wong on 4/15/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import "AVMutableVideoCompositionLayerInstruction+THAdditions.h"
#import <objc/runtime.h>

@implementation AVMutableVideoCompositionLayerInstruction (THAdditions)

static id THTransformKey;

- (CGAffineTransform)transform {
    return [objc_getAssociatedObject(self, &THTransformKey) CGAffineTransformValue];
}

- (void)setTransform:(CGAffineTransform)transform {
    objc_setAssociatedObject(self, &THTransformKey, [NSValue valueWithCGAffineTransform:transform], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
