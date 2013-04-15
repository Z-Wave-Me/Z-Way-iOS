//
//  NSData+Encoding.m
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

#import "NSData+Encoding.h"
#import "Base64Transcoder.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Encoding)

#pragma mark - Base64 encoding

- (NSString*)base64EncodedBytes
{
    @try
    {
        size_t base64EncodedLength = EstimateBas64EncodedDataSize([self length]);
        char base64Encoded[base64EncodedLength];
        const void* cByteValue = [self bytes];
        if(Base64EncodeData(cByteValue, self.length, base64Encoded, &base64EncodedLength))
        {
            return [[NSString alloc] initWithBytes:base64Encoded length:base64EncodedLength encoding:NSASCIIStringEncoding];
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
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    CC_SHA1(self.bytes, self.length, digest);

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
    uint8_t digest[CC_MD5_DIGEST_LENGTH] = {0};
    CC_SHA1(self.bytes, self.length, digest);
    
    NSData *outData = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    
    // description converts to hex but puts <> around it and spaces every 4 bytes
    NSString *hash = [outData description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
}

@end
