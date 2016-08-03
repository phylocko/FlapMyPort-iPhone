//
//  FlapManager.m
//  TabBarTest-2
//
//  Created by Владислав Павкин on 14.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import "FlapManager.h"

@implementation FlapManager

@synthesize delegate;


+ (FlapManager *)sharedInstance
{
    static FlapManager * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FlapManager alloc] init];
    });
    return _sharedInstance;
}


#pragma mark - Getting URLs

- (void)getURL:(NSString *)url
{
	NSLog(@"Requesting url. %@", url);
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    if([[NSURLConnection alloc] initWithRequest:request delegate:self])
    {
        //NSLog(@"Success.");
    }
    else
    {
		NSError *error = [[NSError alloc] initWithDomain:@"Неизвестная ошибка" code:0 userInfo:nil];
		
		[delegate connectionError:error];
    }
}


#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [_responseData appendData:data];
    // NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}



- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {

    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *myData = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    if (myData.length < 6)
    {
        _responseData = nil;
    }

    [delegate refresh:_responseData];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@" - - Connection error.");
    [delegate connectionError:error];

}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSLog(@"\n\n -- I've got an SSL auth type\n\n");

        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        //[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
        NSLog(@"\n\n -- I've got an HTTPBasic auth type\n\n");
    
        // Проламываемся мимо апачёвой авторизации
        /*
         _userLogin		= [[NSUserDefaults standardUserDefaults] valueForKey:@"flapsUserLogin"];
         _userPassword	= [[NSUserDefaults standardUserDefaults] valueForKey:@"flapsUserPassword"];
	
         [[challenge sender] useCredential:[NSURLCredential credentialWithUser:_userLogin password:_userPassword persistence:NSURLCredentialPersistenceForSession] forAuthenticationChallenge:challenge];
     
         if( [challenge previousFailureCount] > 1)
         {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            NSError *error = [[NSError alloc] initWithDomain:@"Неверные логин/пароль" code:0 userInfo:nil];
            [delegate connectionError:error];
         }
         */
    }
}

@end
