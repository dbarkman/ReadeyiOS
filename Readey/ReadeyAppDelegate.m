//
//  ReadeyAppDelegate.m
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyAppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "PocketAPI.h"
#import <RestKit/RestKit.h>

@implementation ReadeyAppDelegate

@synthesize readeyAPIClient;

UINavigationController *navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Flurry startSession:kFlurryAPIKey];
	
	readeyAPIClient = [[ReadeyAPIClient alloc] init];

    DBSession* dbSession = [[DBSession alloc] initWithAppKey:kDropboxAppKey appSecret:kDropboxAppSecret root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
	[Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
	
	[[PocketAPI sharedAPI] setConsumerKey:kPocketAPIKey];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[PocketAPI sharedAPI] handleOpenURL:url]) {
        return YES;

    } else if ([[DBSession sharedSession] handleOpenURL:url]) {
		NSMutableDictionary *flurryParams = [[NSMutableDictionary alloc] init];

		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Readey" bundle:nil];
		UIViewController *leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
		UIViewController *rightViewController = [storyboard instantiateViewControllerWithIdentifier:@"rightViewController"];
		
		if ([[DBSession sharedSession] isLinked]) {
			[flurryParams setObject:@"yes" forKey:@"Authed"];
			DropboxViewController *dropboxViewController = [[DropboxViewController alloc] init];
			[dropboxViewController setTitle:@"Dropbox"];

			IIViewDeckController *deckController = [[IIViewDeckController alloc]
													initWithCenterViewController:dropboxViewController
													leftViewController:leftViewController
													rightViewController:rightViewController];
			[[self window] setRootViewController:deckController];
		} else {
			[flurryParams setObject:@"no" forKey:@"Authed"];
		}
		[Flurry logEvent:@"Dropbox Authed" withParameters:flurryParams];
		return YES;
	}
	return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
