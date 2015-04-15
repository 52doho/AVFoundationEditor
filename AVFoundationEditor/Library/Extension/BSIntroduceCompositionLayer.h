//
//  BSIntroduceCompositionLayer.h
//  AVFoundationEditor
//
//  Created by Guichao Huang (Gary) on 4/12/15.
//  Copyright (c) 2015 TapHarmonic, LLC. All rights reserved.
//

#import "THCompositionLayer.h"

@interface BSIntroduceCompositionLayer : THCompositionLayer

@property(nonatomic, assign) CGRect bounds; // defaults to (0, 0, 720, 720)
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *team;
@property(nonatomic, assign) CFTimeInterval beginTimeOfClosing;
@end