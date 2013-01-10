//
//  Client.h
//  Readey
//
//  Created by David Barkman on 1/9/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UGClient.h"

@interface Client : NSObject

@property (nonatomic, strong) UGClient *usergridClient;
@property (nonatomic, strong) UGUser *user;

-(bool)login:(NSString*)username withPassword:(NSString*)password;

-(bool)createUser:(NSString*)username
		 withName:(NSString*)name
        withEmail:(NSString*)email
	 withPassword:(NSString*)password;

@end
