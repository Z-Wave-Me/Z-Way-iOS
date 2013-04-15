//
//  NSString+Encoding.m
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

#import "NSString+Encoding.h"
#import "Base64Transcoder.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Encoding)

#pragma mark - url encode/decode functions

- (NSString*)urlencodedValue
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
}

- (NSString*)urldecodedValue
{
    return (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)self, (CFStringRef)@"");
}

#pragma mark - Base64 decoding

- (NSData*)base64DecodedBytes
{
    @try
    {
        size_t base64DecodedLength = EstimateBas64DecodedDataSize([self length]);
        char base64Decoded[base64DecodedLength];
        const char* cStringValue = [self UTF8String];
        if(Base64DecodeData(cStringValue, strlen(cStringValue), base64Decoded, &base64DecodedLength))
        {
            return [[NSData alloc] initWithBytes:base64Decoded length:base64DecodedLength];
        }
    }
    @catch (NSException *e)
    {
        //do nothing
        NSLog(@"exception: %@", [e reason]);
    }
    return nil;
}

#pragma mark - hashing

- (NSString *)toSHA1string
{    
    // Using UTF8Encoding
    const char *s = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    CC_SHA1(s, strlen(s), digest);

    NSData *outData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    
    // description converts to hex but puts <> around it and spaces every 4 bytes
    NSString *hash = [outData description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
   
    return hash;
}

- (NSString *)toMD5string
{    
    // Using UTF8Encoding
    const char *s = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_MD5_DIGEST_LENGTH] = {0};
    CC_SHA1(s, strlen(s), digest);
    
    NSData *outData = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    
    // description converts to hex but puts <> around it and spaces every 4 bytes
    NSString *hash = [outData description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
}

@end
