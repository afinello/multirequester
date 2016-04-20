//
//  Requester.m
//  multirequester
//
//  Created by Vladimir Afinello on 19.04.16.
//

#import "Requester.h"
#import "RequestHandler.h"

@interface Requester()<RequestHandlerDelegate>

@property (nonatomic, strong) NSMutableArray* handlers;
@property NSInteger count;
@property NSInteger countOk;
@property NSInteger countError;
@property double avgResponseTime;

@property NSMutableDictionary* statusCodes;

@end

@implementation Requester

- (id) init
{
    self = [super init];
    if(self){
        self.handlers = [NSMutableArray new];
        self.statusCodes = [NSMutableDictionary new];
        self.avgResponseTime = 0.f;
    }
    return self;
}

- (void) startRequestsToURL:(NSString *)url count:(NSInteger)count
{
    self.count = count;
    self.countOk = 0;
    self.countError = 0;
    
    for(NSInteger i = 0; i < count; i++){
        RequestHandler* handler = [[RequestHandler alloc] initWithURL:[NSURL URLWithString:url]];
        handler.delegate = self;
        [self.handlers addObject:handler];
        
        [handler start];
    }
}

- (NSInteger) getActiveRequestsCount
{
    @synchronized (self) {
        return self.handlers.count;
    }
}

- (NSInteger) getErrorsCount
{
    @synchronized (self) {
        return self.countError;
    }
}

- (NSDictionary*) getStats
{
    @synchronized (self) {
        return self.statusCodes;
    }
}

- (double) getResponseTime
{
    @synchronized (self) {
        return self.avgResponseTime;
    }
}

#pragma mark - RequestsHandler delegate

- (void) requestHandler:(id)handler finishedWithError:(NSError *)error statusCode:(NSInteger)statusCode responseTime:(double)responseTime
{
    @synchronized (self) {
        if(error){
            self.countError++;
        } else {
            self.countOk++;
        }
        
        [self.handlers removeObject:handler];
        
        NSNumber* codeKey = [NSNumber numberWithInteger:statusCode];
        NSNumber* codesCount = [self.statusCodes objectForKey:codeKey];
        if(codesCount){
            codesCount = [NSNumber numberWithInteger:[codesCount integerValue] + 1];
        } else {
            codesCount = @(1);
        }
        [self.statusCodes setObject:codesCount forKey:codeKey];
        
        self.avgResponseTime = (self.avgResponseTime + responseTime)/2;
    }
}


@end
