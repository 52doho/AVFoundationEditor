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

#import "THVideoItemTableViewCell.h"
#import "THThumbnailView.h"

@interface THVideoItemTableViewCell ()
@property (nonatomic, strong) THVideoPickerOverlayView *overlayView;
@end

@implementation THVideoItemTableViewCell

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundView = [[THThumbnailView alloc] initWithFrame:self.bounds];
		self.contentView.backgroundColor = [UIColor clearColor];
		_overlayView = [[THVideoPickerOverlayView alloc] initWithFrame:self.bounds];
		_overlayView.hidden = YES;
		[self.contentView addSubview:_overlayView];
	}
	return self;
}

- (void)setThumbnails:(NSArray *)thumbnails {
	[(THThumbnailView *)self.backgroundView setThumbnails:thumbnails];
}

- (UIButton *)playButton {
	return self.overlayView.playButton;
}

- (UIButton *)addButton {
	return self.overlayView.addButton;
}

- (void)setShowOverlayView:(BOOL)showOverlayView {
	_showOverlayView = showOverlayView;
	
	self.overlayView.hidden = !showOverlayView;
	if (!showOverlayView) {
		self.overlayView.playButton.selected = NO;
	}
}

@end

