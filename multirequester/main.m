//
//  main.m
//  multirequester
//
//  Created by Vladimir Afinello on 19.04.16.
//

#import <Foundation/Foundation.h>
#import "Requester.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // two parameters are required
        if (argc!=3)
        {
            // output usage
            printf("Usage: multirequester <url> <count>\n\turl - server URL\n\tcount - number of requests to try\n");
            
            exit(1);
        }
        
        NSString* url = [NSString stringWithUTF8String:argv[1]];
        NSInteger count = [[NSString stringWithFormat:@"%s", argv[2]] intValue];
        Requester* requester = [[Requester alloc] init];
        
        printf("Executing...\n");
        CFAbsoluteTime timeStart = CFAbsoluteTimeGetCurrent();
        
        [requester startRequestsToURL:url count:count];
        NSInteger active = count;
        do {
        
            usleep(100);
            active = [requester getActiveRequestsCount];
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        } while (active > 0);
        
        CFAbsoluteTime timeEnd = CFAbsoluteTimeGetCurrent();
        double timeDelta = timeEnd - timeStart;
        NSInteger errors = [requester getErrorsCount];
        CGFloat percentage = (CGFloat) errors / count * 100;
        double avgResponseTime = [requester getResponseTime];
        
        printf("Done %ld requests in %4.4f sec\n - %ld requests per second\n - %ld failured (%3.2f%%)\nAvg response time: %4.4f sec\n",
              (long)count,
              timeDelta,
              (long) ((CGFloat) count / timeDelta),
              (long)errors,
              percentage,
              avgResponseTime);
        
        printf("HTTP status codes:\n");
        NSDictionary* codes = [requester getStats];
        for(NSNumber* code in [codes allKeys]){
            printf(" %ld: %ld\n", (long)[code integerValue], (long)[[codes objectForKey:code] integerValue]);
        }
    }
    return 0;
}
