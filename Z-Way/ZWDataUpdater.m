//
//  ZWDataUpdater.m
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

#import "ZWDataUpdater.h"

@implementation ZWDataUpdater

- (id)initWithDelegate:(id<ZWDataUpdaterEvents>)delegate
{
    if (self = [super init])
    {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];

    _delegate = nil;
    _connection = nil;
    _credentials = nil;
    _data = nil;
}

- (void)setCredentials:(NSURLCredential *)credentials
{
    _credentials = credentials;
}

#pragma mark -
#pragma mark Network events

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    _connection = nil;
    
    if (_data == nil) return;
    
    BOOL success = NO;
    @try
    {
        [self processResults:_data];
        success = YES;
    }
    @catch (NSException *exception)
    {
        [self handleError:exception.reason];
    }
    @finally
    {
        _data = nil;
        [_delegate updaterFinished:self withResult:success];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection cancel];
    _data = nil;
    _connection = nil;    
    [_delegate updaterFinished:self withResult:NO];
    [self handleError:error.localizedDescription];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    NSString* method = protectionSpace.authenticationMethod;
    return [method isEqualToString:NSURLAuthenticationMethodServerTrust] || [method isEqualToString:NSURLAuthenticationMethodDefault];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSString *method = challenge.protectionSpace.authenticationMethod;
    
    if ([method isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodDefault] && _credentials != nil)
    {
        if ([challenge previousFailureCount] > 0)
        {
            [challenge.sender cancelAuthenticationChallenge:challenge];
            [_delegate authorizationFailure:self];
        }
        else
        {
            [challenge.sender useCredential:_credentials forAuthenticationChallenge:challenge];
        }
    }

    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self handleResponse:(NSHTTPURLResponse*)response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

#pragma mark -
#pragma mark Overridable methods

- (NSURLRequest*)createRequest
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)processResults:(NSData *)data
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)handleError:(NSString *)error
{
    NSLog(@"Error: %@", error);
}

- (void)handleResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode == 403)
    {
        NSLog(@"Error: unauthorized");
    }
}

#pragma mark -
#pragma mark Start and Cancel methods

- (void)start
{
    [_connection cancel];
    
    @try
    {
        NSURLRequest* request = [self createRequest];
        if (request == nil)
        {
            _data = nil;
            [_delegate updaterFinished:self withResult:NO];
            return;
        }
        
        _data = [NSMutableData dataWithCapacity:2048];
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    @catch (NSException *exception)
    {
        _data = nil;
        [_delegate updaterFinished:self withResult:NO];
        [self handleError:exception.reason];
    }
}

- (void)cancel
{
    if (_connection != nil)
    {
        [_connection cancel];
        _connection = nil;
        
        if ([_delegate respondsToSelector:@selector(updaterCancelled:)])
        {
            [_delegate updaterCancelled:self];
        }
    }
    _data = nil;
}


@end
