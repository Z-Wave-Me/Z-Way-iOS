//
//  ZWBlindsControl.m
//  Z-Way
//
//  Created by Alex Skalozub on 9/4/12.
//  Copyright (c) 2012 Alex Skalozub.
//
//  Z-Way for iOS is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  Z-Way for iOS is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with Z-Way for iOS. If not, see <http://www.gnu.org/licenses/>
//

#import "ZWBlindsControl.h"

@implementation ZWBlindsControl

@synthesize pressedSegmentIndex = _segmentIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isHold = NO;
        
    }
    return self;
}

- (void)valueChangedHandler:(id)sender
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isHold = YES;
    [super touchesBegan:touches withEvent:event];
    _segmentIndex = self.selectedSegmentIndex;
    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    [self performSelector:@selector(checkHold) withObject:nil afterDelay:0.3];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    _isHold = NO;
    
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
    [self setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isHold = NO;
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
    [self setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

- (void)checkHold
{
    if (_isHold)
    {
        [self sendActionsForControlEvents:UIControlEventTouchDownRepeat];
    }
}

@end
