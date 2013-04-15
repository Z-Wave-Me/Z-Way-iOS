//
//  ZWRootViewCell.h
//  Z-Way
//
//  Created by Alex Skalozub on 8/22/12.
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

#import <Foundation/Foundation.h>

@interface ZWRootViewCell : NSObject

- (id)initWithTitle:(NSString*)title andImage:(NSString*)image andClass:(__unsafe_unretained Class)cls forIdentifier:(NSString*)identifier;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *image;
@property (assign) Class pageClass;
@property (strong, nonatomic) NSString *identifier;

@end
