//
//  ZWDataUpdater.h
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

#import <Foundation/Foundation.h>
#import "ZWDataUpdaterEvents.h"

@interface ZWDataUpdater : NSObject<NSURLConnectionDelegate>
{
    id<ZWDataUpdaterEvents> _delegate;
    NSURLConnection* _connection;
    NSMutableData* _data;
    NSURLCredential* _credentials;
}

- (id)initWithDelegate:(id<ZWDataUpdaterEvents>)delegate;

- (void)setCredentials:(NSURLCredential*)credentials;

// init request (for inheriting in subclasses)
- (NSURLRequest*)createRequest;

// process results (for inheriting in subclasses)
- (void)processResults:(NSData*)data;

// handle error (optional overriding in subclasses)
- (void)handleError:(NSString*)error;

// handle response (optional overriding in subclasses)
- (void)handleResponse:(NSHTTPURLResponse*)response;

// start async update operation
- (void)start;

// cancel async update operation
- (void)cancel;

@end