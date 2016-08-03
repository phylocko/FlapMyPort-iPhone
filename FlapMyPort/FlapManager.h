//
//  FlapManager.h
//  TabBarTest-2
//
//  Created by Владислав Павкин on 14.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlapManagerDelegate

@property NSMutableData *data;

- (void)refresh:(NSMutableData *)data;

- (void)connectionError:(NSError *)error;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@interface FlapManager : NSObject <NSURLConnectionDelegate>
{
    NSMutableData * _responseData;
}

+ (FlapManager *) sharedInstance;

@property NSString *userLogin;
@property NSString *userPassword;

@property (nonatomic, strong) id delegate;

- (void)getURL:(NSString *)url;

@end
