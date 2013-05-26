//
//  ReadeyViewController.m
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyViewController.h"
#import "NSString_stripHtml.h"
#import "WebViewController.h"

#define CURRENT_WORD_LABEL_TAG 101

@implementation ReadeyViewController

@synthesize rssItemUuid, category, sourceUrl, sourceEnabled, articleContent, articleIdentifier;
@synthesize client;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[Flurry logEvent:@"ReadeyView"];
	
	client.delegate = self;
	
	if (sourceEnabled == false) [sourceButton setHidden:YES];

	[self setReaderColor];
	
	[currentWord setTag:CURRENT_WORD_LABEL_TAG];
    
	jumpBack = false;
	jumpForward = false;
	
	[timer invalidate];
	
	CGFloat height = [[UIScreen mainScreen] bounds].size.height;
	CGRect frame = [currentWord frame];
	frame.origin.y = (height - frame.size.height) / 2;
	[currentWord setFrame:frame];
	
	marker = 0;
	
	//setup the regex to find and remove easy html
//	NSRegularExpression *regexImageTag = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//setup the regex to find short-hyphen hyphenated-words and make them into hyphenated- words
	NSRegularExpression *regexShortHyphen = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z]+-)" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//setup the regex to find long—hyphen hyphenated-words and make them into hyphenated- words
	NSRegularExpression *regexSlash = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z]+/)" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//apply the above regex for easy html
//	NSString *articlecontent0 = [regexImageTag stringByReplacingMatchesInString:articleContent options:0 range:NSMakeRange(0, [articleContent length]) withTemplate:@""];
	
	//remove all html content with stripHTML - not sureif this is needed
//	NSString *articleContent1 = [articlecontent0 stripHtml];
	
	//apply the above regex for short-hyphenated-words
	NSString *articlecontent2 = [regexShortHyphen stringByReplacingMatchesInString:articleContent options:0 range:NSMakeRange(0, [articleContent length]) withTemplate:@"$1 "];
	
	//apply the above regex for long-hyphenated-words
	NSString *articlecontent3 = [regexSlash stringByReplacingMatchesInString:articlecontent2 options:0 range:NSMakeRange(0, [articlecontent2 length]) withTemplate:@"$1 "];
	
	//seperate the results of the above fixes into an array, one word per array entry
	NSArray *tempArray = [articlecontent3 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	//elimenates blank spots in the array
	wordArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
	wordArraySize = [wordArray count];
	
	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	if (wpm.length == 0) {
		wpm = @"200";
		[[NSUserDefaults standardUserDefaults] setObject:wpm forKey:@"wpm"];
	}
	int wpmInt = [wpm integerValue];

	wordsPerMinute = wpmInt;
	rate = 60.0 / wordsPerMinute;
	
	startingWPM = wpmInt;
	
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSMutableDictionary *flurryParams = [[NSMutableDictionary alloc] init];
	float wpmDifference = startingWPM - wordsPerMinute;
	if (wpmDifference > 0) {
		[flurryParams setObject:@"slowed" forKey:@"change"];
	} else if (wpmDifference < 0) {
		[flurryParams setObject:@"sped up" forKey:@"change"];
	} else {
		[flurryParams setObject:@"no change" forKey:@"change"];
	}
	[Flurry logEvent:@"WPM Change When Article Complete" withParameters:flurryParams];
	
	NSString *wpmString = [NSString stringWithFormat:@"%d", (int)wordsPerMinute];
	[[NSUserDefaults standardUserDefaults] setObject:wpmString forKey:@"wpm"];
}

- (IBAction)switchColor
{
	NSString *readerColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"readerColor"];

	if ([readerColor isEqualToString:@"dark"]) {
		readerColor = @"light";
		[darkLightButton setTitle:@"Dark" forState:UIControlStateNormal];
	} else {
		readerColor = @"dark";
		[darkLightButton setTitle:@"Light" forState:UIControlStateNormal];
	}
	
	NSDictionary *flurryParams = [[NSDictionary alloc] initWithObjectsAndKeys:readerColor, @"Color", nil];
	[Flurry logEvent:@"Changed Reader Color" withParameters:flurryParams];
	
	[[NSUserDefaults standardUserDefaults] setObject:readerColor forKey:@"readerColor"];

	[self setReaderColor];
}

- (void)setReaderColor
{
	NSArray *buttons = [[NSArray alloc] initWithObjects:navigateBackButton, sourceButton, darkLightButton, startButton, backButton, slowerButton, masterButton, fasterButton, nextButton, endButton, nil];
	NSArray *labels = [[NSArray alloc] initWithObjects:wpmRate, timeRemaining, words, timeToRead, averageSpeed, nil];
	
	NSString *readerColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"readerColor"];

	NSDictionary *flurryParams = [[NSDictionary alloc] initWithObjectsAndKeys:readerColor, @"Color", nil];
	[Flurry logEvent:@"Starting Reader Color" withParameters:flurryParams];
	
	if ([readerColor isEqualToString:@"dark"]) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
		
		[darkLightButton setTitle:@"Light" forState:UIControlStateNormal];
		
		UIImage *buttonBackgroundImage = [[UIImage imageNamed:@"blackButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		UIImage *buttonBackgroundImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		
		[self setButton:buttonBackgroundImage withHightlight:buttonBackgroundImageHighlight];
		
		[self.view setBackgroundColor:kOffBlackColor];
		for (UIButton *button in buttons) [button setTitleColor:kLightGrayColor forState:UIControlStateNormal];
		for (UILabel *label in labels) [label setTextColor:kLightGrayColor];
		[currentWord setTextColor:kOffWhiteColor];
		[progress setProgressTintColor:kOffBlackColor];
		[progress setTrackTintColor:kOffBlackColor];
	} else {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
		
		[darkLightButton setTitle:@"Dark" forState:UIControlStateNormal];

		UIImage *buttonBackgroundImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		UIImage *buttonBackgroundImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		
		[self setButton:buttonBackgroundImage withHightlight:buttonBackgroundImageHighlight];
		
		[self.view setBackgroundColor:kLightGrayColor];
		for (UIButton *button in buttons) [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		for (UILabel *label in labels) [label setTextColor:[UIColor darkGrayColor]];
		[currentWord setTextColor:[UIColor blackColor]];
		[progress setProgressTintColor:kLightGrayColor];
		[progress setTrackTintColor:kLightGrayColor];
	}
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch *touch = [touches anyObject];
	
	if (touch.view.tag == 101) {
		[Flurry logEvent:@"Tapped Current Word"];
		if ([timer isValid]) {
			[self pause];
		} else {
			[self play];
		}
	}
}

- (IBAction)back
{
	[Flurry logEvent:@"Tapped Back"];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
	
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)source
{
	[Flurry logEvent:@"Tapped Source"];
	
	WebViewController *webViewController = [[WebViewController alloc] initWithURL:sourceUrl];
	[webViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentViewController:webViewController animated:YES completion:nil];
	[client createReadLogWithSpeed:0 andWords:0 forRssItem:rssItemUuid withCategory:category];
}

- (void)updateCounters:(bool)animated
{
	float timeRemain = (wordArraySize - marker) * rate;
	int minutes = floor(timeRemain / 60);
	int seconds = timeRemain - (minutes * 60);
	[timeRemaining setText:[NSString stringWithFormat:@"%d:%02d time", minutes, seconds]];
	[words setText:[NSString stringWithFormat:@"%d words", wordArraySize - marker]];
    [progress setProgress:(1.0 / wordArraySize) * marker animated:animated];
}

- (IBAction)startTapped
{
	[Flurry logEvent:@"Tapped Start"];
	[self start:NO];
}

- (void)start:(bool)andGo
{
    [navigateBackButton setHidden:NO];
	if (sourceEnabled == true) [sourceButton setHidden:NO];
	[self changeDarkLight:NO];

	[timer invalidate];
	
	marker = 0;
    
    [self updateCounters:!andGo];
	
	[self setToPlay];
	
	if (!andGo) [currentWord setText:@"Ready?"];
}

- (IBAction)prevWord
{
	[Flurry logEvent:@"Tapped Previous"];
	
	jumpForward = true;
	if (jumpBack == true) {
		jumpBack = false;
		marker--;
	}
	if (marker > 0) {
		marker--;
		NSString *word = [wordArray objectAtIndex:marker];
		if ([word length] == 0) {
			NSDictionary *flurryParams = [[NSDictionary alloc] initWithObjectsAndKeys:articleIdentifier, @"Identifier", marker, @"Marker", nil];
			[Flurry logEvent:@"Blank Word on Next" withParameters:flurryParams];
		}
		[currentWord setText:word];
        [self updateCounters:YES];
	}
}

- (IBAction)slower
{
	if (wordsPerMinute > 5) {
		[Flurry logEvent:@"Tapped Slower"];
		
		wordsPerMinute = wordsPerMinute - 5;
		rate = 60.0 / wordsPerMinute;
		if ([timer isValid]) [self resetTimer];
		[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
		[self updateCounters:YES];
	} else {
		[Flurry logEvent:@"Tapped Slower - At 0"];
	}
}

- (IBAction)playTapped
{
	[Flurry logEvent:@"Tapped Play"];
	[self play];
}

- (void)play
{
	if (marker == wordArraySize) {
		[self start:YES];
	}
    [navigateBackButton setHidden:YES];
	[sourceButton setHidden:YES];

	[self resetTimer];
    if (marker == 0) startTime = [NSDate date];
	[self setToPause];
}

- (IBAction)pauseTapped
{
	if ([timer isValid]) {
		[Flurry logEvent:@"Tapped Pause"];
		[self pause];
	}
}

- (void)pause
{
	if ([timer isValid]) {
		[navigateBackButton setHidden:NO];
		if (sourceEnabled == true) [sourceButton setHidden:NO];
		
		[timer invalidate];
		[self setToPlay];
	}
}

- (IBAction)faster
{
	if (wordsPerMinute < 800) {
		[Flurry logEvent:@"Tapped Faster"];
		wordsPerMinute = wordsPerMinute + 5;
		rate = 60.0 / wordsPerMinute;
		if ([timer isValid]) [self resetTimer];
		[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
		[self updateCounters:YES];
	} else {
		[Flurry logEvent:@"Tapped Faster - At 800"];
	}
}

- (IBAction)nextWordTapped
{
	[Flurry logEvent:@"Tapped Next"];
	[self nextWord];
}

- (void)nextWord
{
	jumpBack = true;
	if (jumpForward == true) {
		jumpForward = false;
		marker++;
	}
	if (marker < wordArraySize) {
		NSString *word = [wordArray objectAtIndex:marker];
		marker++;
		if ([word length] == 0) {
			NSDictionary *flurryParams = [[NSDictionary alloc] initWithObjectsAndKeys:articleIdentifier, @"Identifier", marker, @"Marker", nil];
			[Flurry logEvent:@"Blank Word on Next" withParameters:flurryParams];
		}
		[currentWord setText:word];
        finishTime = [NSDate date];
		[self updateCounters:YES];
	} else if (marker == wordArraySize) {
		[self end];
	}
}

- (IBAction)endTapped
{
	[Flurry logEvent:@"Tapped End"];
	[self end];
}

- (void)end
{
	[currentWord setText:@"Complete!"];

	if (marker != wordArraySize) {
		marker = wordArraySize;
		[self updateCounters:NO];
	}
	[navigateBackButton setHidden:NO];
	if (sourceEnabled == true) [sourceButton setHidden:NO];

	[timer invalidate];
	
	[progress setProgress:1.0];
	
	[self setToPlay];
	
	[self changeDarkLight:YES];
	
	NSTimeInterval difference = [finishTime timeIntervalSinceDate:startTime];
	int minutes = floor(difference / 60);
	int seconds = difference - (minutes * 60);
	NSString *timeToReadResult = [NSString stringWithFormat:@"Time: %d:%02d", minutes, seconds];

	float speed = wordArraySize * (60 / difference);
	NSString *averageSpeedResult = [NSString stringWithFormat:@"Speed: %.0f wpm", speed];
	if (startTime == NULL) {
		timeToReadResult = @"Time: 0:00";
		averageSpeedResult = @"Speed: 0 wpm";
		difference = 0;
		speed = 0.0;
	}
	[timeToRead setText:timeToReadResult];
	[averageSpeed setText:averageSpeedResult];
	
	NSDictionary *flurryParamsTimeRead = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", (int)difference], @"Time", nil];
	[Flurry logEvent:@"Time Read" withParameters:flurryParamsTimeRead];
	
	NSDictionary *flurryParamsSpeedRead = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f", speed], @"Speed", nil];
	[Flurry logEvent:@"Speed Read" withParameters:flurryParamsSpeedRead];
	
	NSDictionary *flurryParamsWords = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", wordArraySize], @"Words", nil];
	[Flurry logEvent:@"Words Read" withParameters:flurryParamsWords];
	
	[client createReadLogWithSpeed:speed andWords:wordArraySize forRssItem:rssItemUuid withCategory:category];
}

- (void)requestReturned:(NSDictionary *)request
{
	[Flurry endTimedEvent:@"POST ReadLog" withParameters:nil];
	
	if (request) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReadLogCreated" object:self];
	}
}

- (void)resetTimer
{
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(nextWord) userInfo:nil repeats:YES];
}

- (void)setToPause
{
	[masterButton setTitle:@"STOP" forState:UIControlStateNormal];
	[masterButton removeTarget:self action:@selector(playTapped) forControlEvents:UIControlEventTouchUpInside];
	[masterButton addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToPlay
{
	[masterButton setTitle:@"GO" forState:UIControlStateNormal];
	[masterButton removeTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
	[masterButton addTarget:self action:@selector(playTapped) forControlEvents:UIControlEventTouchUpInside];
}

//- (void)changeSource:(bool)hide  //shouldn't be needed anymore
//{
//    [sourceButton setHidden:hide];
//	[timeRemaining setHidden:!hide];
//	[words setHidden:!hide];
//	[wpmRate setHidden:!hide];
//}

- (void)changeDarkLight:(bool)hide
{
	[darkLightButton setHidden:hide];
    [timeToRead setHidden:!hide];
    [averageSpeed setHidden:!hide];
}

- (void)setButton:(UIImage *)buttonBackgroundImage withHightlight:(UIImage *)buttonBackgroundImageHighlight
{
    [navigateBackButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [navigateBackButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [sourceButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [sourceButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [darkLightButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [darkLightButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    
	[startButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [backButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [slowerButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [slowerButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [masterButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [masterButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [fasterButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [fasterButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [nextButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [nextButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [endButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [endButton setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
}

@end
