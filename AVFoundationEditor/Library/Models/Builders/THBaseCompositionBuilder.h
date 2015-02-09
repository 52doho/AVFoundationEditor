//
//  THBaseCompositionBuilder.h
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 2/9/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THComposition.h"
#import "THTimeline.h"

@interface THBaseCompositionBuilder : NSObject

@property (nonatomic, strong, readonly) THTimeline *timeline;
@property (nonatomic, assign) CGSize renderSize;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, assign) float transitionDuration;

- (id)initWithTimeline:(THTimeline *)timeline;
- (id <THComposition>)buildComposition;

@end
