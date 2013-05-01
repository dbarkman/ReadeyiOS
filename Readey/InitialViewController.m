//
//  InitialViewController.m
//  Readey
//
//  Created by David Barkman on 4/18/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "InitialViewController.h"

@implementation InitialViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Readey" bundle:nil];
	UIViewController *leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
	UIViewController *centerViewController = [storyboard instantiateViewControllerWithIdentifier:@"centerViewController"];
	UIViewController *rightViewController = [storyboard instantiateViewControllerWithIdentifier:@"rightViewController"];
	
	self = [super initWithCenterViewController:centerViewController
							leftViewController:leftViewController
						   rightViewController:rightViewController];
	
	[self setCenterhiddenInteractivity:IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose];

	if (self) {
		
	}
	return self;
}

@end
