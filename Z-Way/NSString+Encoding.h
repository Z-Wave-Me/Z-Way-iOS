//
//  NSString+Encoding.h
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

@interface NSString (Encoding)

/**
 * returns urlencoded value of this string
 */
- (NSString*)urlencodedValue;

/**
 * returns urldecoded value of this string
 */
- (NSString*)urldecodedValue;

/**
 * returns Base64 decoded bytes
 */
- (NSData*)base64DecodedBytes;

/**
 * returns SHA1 hash as hex string
 */
- (NSString*)toSHA1string;

/**
 * returns MD5 hash as hex string
 */
- (NSString*)toMD5string;


@end