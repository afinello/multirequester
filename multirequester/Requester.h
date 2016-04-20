//
//  Requester.h
//  multirequester
//
//  Created by Vladimir Afinello on 19.04.16.
//

#import <Foundation/Foundation.h>

@interface Requester : NSObject

- (void) startRequestsToURL:(NSString*)url count:(NSInteger)count;
- (NSInteger) getActiveRequestsCount;
- (NSInteger) getErrorsCount;
- (double) getResponseTime;
- (NSDictionary*) getStats;

@end
