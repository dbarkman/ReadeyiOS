//
//  ReadeyAppDelegate.m
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyAppDelegate.h"
#import "FoldersViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxViewController.h"

@implementation ReadeyAppDelegate

UINavigationController *navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIColor *calmingBlue = [UIColor colorWithRed:21/255.0f green:100/255.0f blue:178/255.0f alpha:1];
	NSData *calmingBlueData = [NSKeyedArchiver archivedDataWithRootObject:calmingBlue];
	[[NSUserDefaults standardUserDefaults] setObject:calmingBlueData forKey:@"calmingBlue"];

    DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"py9e1yuyy55owpb" appSecret:@"ai5j37a4ss5wz1g" root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    FoldersViewController *foldersViewController = [[FoldersViewController alloc] init];
            
    navigationController = [[UINavigationController alloc] initWithRootViewController:foldersViewController];
    [navigationController.navigationBar setTintColor:calmingBlue];
            
    [[self window] setRootViewController:navigationController];
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
			DropboxViewController *dropboxViewController = [[DropboxViewController alloc] init];
			[dropboxViewController setTitle:@"Dropbox"];
			[navigationController pushViewController:dropboxViewController animated:YES];
		}
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
