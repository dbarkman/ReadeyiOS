//
//  ReadeyViewController.h
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadeyAPIClient.h"

@interface ReadeyViewController : UIViewController <ReadeyClientDelegate>
{
	int marker;
	int wordArraySize;
	float rate;
	float wordsPerMinute;
	float startingWPM;
	bool jumpBack;
	bool jumpForward;
	NSArray *wordArray;
	NSTimer *timer;
	NSDate *startTime;
	NSDate *finishTime;
	
	IBOutlet UILabel *wpmRate;
	IBOutlet UILabel *timeRemaining;
	IBOutlet UILabel *words;
	IBOutlet UILabel *currentWord;
	IBOutlet UILabel *timeToRead;
	IBOutlet UILabel *averageSpeed;
    IBOutlet UIProgressView *progress;

    IBOutlet UIButton *navigateBackButton;
	IBOutlet UIButton *darkLightButton;
    IBOutlet UIButton *sourceButton;

	IBOutlet UIButton *startButton;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *slowerButton;
	IBOutlet UIButton *masterButton;
	IBOutlet UIButton *fasterButton;
	IBOutlet UIButton *nextButton;
	IBOutlet UIButton *endButton;
}

- (IBAction)back;
- (IBAction)source;
- (IBAction)switchColor;

- (IBAction)startTapped;
- (IBAction)prevWord;
- (IBAction)slower;
- (IBAction)playTapped;
- (IBAction)pauseTapped;
- (IBAction)faster;
- (IBAction)nextWordTapped;
- (IBAction)endTapped;

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

@property (nonatomic, strong) ReadeyAPIClient *client;
@property (nonatomic) bool sourceEnabled;
@property (nonatomic, strong) NSString *rssItemUuid;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *sourceUrl;
@property (nonatomic, strong) NSString *articleContent;
@property (nonatomic, strong) NSString *articleIdentifier;

@end
