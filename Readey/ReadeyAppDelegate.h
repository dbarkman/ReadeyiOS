//
//  ReadeyAppDelegate.h
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadeyAPIClient.h"

@interface ReadeyAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ReadeyAPIClient *readeyAPIClient;

@end
