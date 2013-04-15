//
//  ZWCategoryItem.m
//  Z-Way
//
//  Created by Alex Skalozub on 8/18/12.
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

#import "ZWCategoryItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation ZWCategoryItem

@synthesize content = _content;
@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.content = [[UIView alloc] initWithFrame:frame];
        _content.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _content.layer.cornerRadius = 8;
        _content.layer.masksToBounds = YES;
        _content.layer.shadowRadius = 5;
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.opaque = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        }
        else
        {
            _titleLabel.font = [UIFont boldSystemFontOfSize:26];
        }
        
        self.imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        
        [_content addSubview:_imageView];
        [_content addSubview:_titleLabel];
        
        self.contentView = self.content;
    }
    return self;
}

- (void)dealloc
{
    self.imageView = nil;
    self.titleLabel = nil;
    self.content = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    _content.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _titleLabel.frame = CGRectMake(0, frame.size.height - 20, frame.size.width, 18);
        _imageView.frame = CGRectMake(20, 15, frame.size.width - 40, frame.size.height - 40);
    }
    else
    {
        _titleLabel.frame = CGRectMake(0, frame.size.height - 34, frame.size.width, 28);
        _imageView.frame = CGRectMake(40, 30, frame.size.width - 80, frame.size.height - 80);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
