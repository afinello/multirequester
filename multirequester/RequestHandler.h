//
//  RequestHandler.h
//  multirequester
//
//  Created by Vladimir Afinello on 19.04.16.
//

#import <Foundation/Foundation.h>

@protocol RequestHandlerDelegate <NSObject>

- (void) requestHandler:(id)handler finishedWithError:(NSError*)error statusCode:(NSInteger)statusCode responseTime:(double)responseTime;

@end

@interface RequestHandler : NSObject<NSURLConnectionDelegate>

@property (nonatomic, assign) id<RequestHandlerDelegate> delegate;
@property (nonatomic, strong) NSURL* url;

- (id) initWithURL:(NSURL*)url;
- (void) start;

@end
