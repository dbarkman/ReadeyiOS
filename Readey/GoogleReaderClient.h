//
//  GoogleReaderClient.h
//  Readey
//
//  Created by David Barkman on 2/4/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleReaderClient : NSObject

- (NSString *)getAuthToken;
- (NSMutableArray *)getSubscriptionList:(NSString *)authToken;

@end
