//
//  ZWRulesLoader.m
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

#import "ZWRulesLoader.h"
#import "CMProfile.h"
#import "TFHpple.h"

@implementation ZWRulesLoader

@synthesize xml = _xml;

- (id)initWithProfile:(CMProfile*)profile andDelegate:(id<ZWDataUpdaterEvents>)delegate
{
    NSParameterAssert(profile != nil);
    
    self = [super initWithDelegate:delegate];
    if (self)
    {
        _profile = profile;
    }
    return self;
}

- (void)dealloc
{
    _profile = nil;
    _xml = nil;
}

- (NSURLRequest*)createRequest
{
    NSURL *rootUrl;
    
    if ([_profile.useOutdoor boolValue] && _profile.outdoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.outdoorUrl];
    }
    else if (![_profile.useOutdoor boolValue] && _profile.indoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.indoorUrl];
    }
    else if (_profile.indoorUrl.length > 0)
    {
        rootUrl = [NSURL URLWithString:_profile.indoorUrl];
    }
    else
    {
        rootUrl = [NSURL URLWithString:_profile.outdoorUrl];
    }
    
    NSURL *fullUrl = [NSURL URLWithString:@"/config/Rules.xml" relativeToURL:rootUrl];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullUrl cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:10];
    
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [theRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    if (_profile.userLogin.length > 0)
    {
        [self setCredentials:[NSURLCredential credentialWithUser:_profile.userLogin password:_profile.userPassword persistence:NSURLCredentialPersistenceNone]];
    }
    
    return theRequest;
}

- (void)handleResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200)
    {
        [_connection cancel];
        _connection = nil;
        _data = nil;
        [_delegate updaterFinished:self withResult:NO];
    }
    else
    {
        [super handleResponse:response];
    }
}

- (void)processResults:(NSData *)data
{
    _xml = [TFHpple hppleWithData:data isXML:YES];
}


@end
