//
//  ZWDataTree.m
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

#import "ZWDataTree.h"
#import "CMProfile.h"
#import "NSData+Encoding.h"

@implementation ZWDataTree

@synthesize profile = _profile;
@synthesize usingExternal = _usingExternal;

- (id)initWithTimestamp:(NSUInteger)timestamp andProfile:(CMProfile *)profile andDelegate:(id<ZWDataUpdaterEvents>)delegate
{
    NSParameterAssert(profile != nil);
    
    self = [super initWithDelegate:delegate];
    if (self)
    {
        _timestamp = timestamp;
        _profile = profile;
    }
    return self;
}

- (void)dealloc
{
    _profile = nil;
}

- (NSURLRequest*)createRequest
{
    NSURL *rootUrl = nil;
    
    if ([_profile.useOutdoor boolValue] && _profile.outdoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.outdoorUrl];
        _usingExternal = YES;
    }
    else if (![_profile.useOutdoor boolValue] && _profile.indoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.indoorUrl];
        _usingExternal = NO;
    }
    else if (_profile.indoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.indoorUrl];
        _usingExternal = NO;
    }
    else if (_profile.outdoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.outdoorUrl];
        _usingExternal = YES;
    }
    
    if (rootUrl == nil) return nil;
    
    NSURL *fullUrl = [NSURL URLWithString:[NSString stringWithFormat:@"/ZWaveAPI/Data/%u", _timestamp] relativeToURL:rootUrl];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullUrl cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:15];

    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [theRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];

    if (_profile.userLogin.length > 0)
    {
        [self setCredentials:[NSURLCredential credentialWithUser:_profile.userLogin password:_profile.userPassword persistence:NSURLCredentialPersistenceNone]];
    }
    
    return theRequest;
}

- (void)processJson:(NSObject *)json
{
    self.json = json;
}

@end
