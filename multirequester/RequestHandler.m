//
//  RequestHandler.m
//  multirequester
//
//  Created by Vladimir Afinello on 19.04.16.
//

#import "RequestHandler.h"

@implementation RequestHandler
{
    NSMutableData *_responseData;
    NSURLConnection *_conn;
    NSInteger _statusCode;
    CFAbsoluteTime _timeStart;
    CFAbsoluteTime _timeEnd;
}

- (id) initWithURL:(NSURL*)url
{
    self = [super init];
    if(self)
    {
        self.url = url;
        _statusCode = 0;
    }
    return self;
}

- (void) start
{
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5.0];
    
    // Create url connection and fire request
    
    _conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    _timeStart = CFAbsoluteTimeGetCurrent();
    [_conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_conn start];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
    
    // get http status code
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    _statusCode = [httpResponse statusCode];
    
    _timeEnd = CFAbsoluteTimeGetCurrent();
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //NSLog(@"%@",[[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding]);
    if([_delegate respondsToSelector:@selector(requestHandler:finishedWithError:statusCode:responseTime:)])
    {
        [_delegate requestHandler:self finishedWithError:nil statusCode:_statusCode responseTime:_timeEnd-_timeStart];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    _timeEnd = CFAbsoluteTimeGetCurrent();
    // The request has failed for some reason!
    if([_delegate respondsToSelector:@selector(requestHandler:finishedWithError:statusCode:responseTime:)])
    {
        [_delegate requestHandler:self finishedWithError:error statusCode:_statusCode responseTime:_timeEnd-_timeStart];
    }
}

@end
