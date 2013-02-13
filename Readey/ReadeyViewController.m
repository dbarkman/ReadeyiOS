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

@implementation ReadeyViewController

@synthesize articleContent, marker, wordArray, wordArraySize;
@synthesize rate, wordsPerMinute, timer, startTime, finishTime;
@synthesize sourceUrl, sourceTitle, sourceEnabled;

bool jumpBack = false;
bool jumpForward = false;

- (IBAction)back
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)source
{
	WebViewController *webViewController = [[WebViewController alloc] initWithURL:sourceUrl title:sourceTitle];
	[webViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentViewController:webViewController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateButton];

	[timer invalidate];
	
	CGFloat height = [[UIScreen mainScreen] bounds].size.height;
	CGRect frame = [currentWord frame];
	frame.origin.y = (height - frame.size.height) / 2;
	[currentWord setFrame:frame];
	
	marker = 0;
	
	//setup the regex to find and remove easy html
	NSRegularExpression *regexImageTag = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//setup the regex to find short-hyphen hyphenated-words and make them into hyphenated- words
	NSRegularExpression *regexShortHyphen = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z]+-)" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//setup the regex to find long—hyphen hyphenated-words and make them into hyphenated- words
	NSRegularExpression *regexLongHyphen = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z]+—)" options:NSRegularExpressionCaseInsensitive error:NULL];
	
	//apply the above regex for easy html
	NSString *articlecontent0 = [regexImageTag stringByReplacingMatchesInString:articleContent options:0 range:NSMakeRange(0, [articleContent length]) withTemplate:@""];
	
	//remove all html content with stripHTML - not sureif this is needed
	NSString *articleContent1 = [articlecontent0 stripHtml];
	
	//apply the above regex for short-hyphenated-words
	NSString *articlecontent2 = [regexShortHyphen stringByReplacingMatchesInString:articleContent1 options:0 range:NSMakeRange(0, [articleContent1 length]) withTemplate:@"$1 "];
	
	//apply the above regex for long-hyphenated-words
	NSString *articlecontent3 = [regexLongHyphen stringByReplacingMatchesInString:articlecontent2 options:0 range:NSMakeRange(0, [articlecontent2 length]) withTemplate:@"$1 "];
	
	//seperate the results of the above fixes into an array, one word per array entry
	NSArray *tempArray = [articlecontent3 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	//elimenates blank spots in the array
	wordArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
	wordArraySize = [wordArray count];
	
	NSString *wpm = [[NSUserDefaults standardUserDefaults] objectForKey:@"wpm"];
	int wpmInt = [wpm integerValue];

	wordsPerMinute = wpmInt;
	rate = 60.0 / wordsPerMinute;
	
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters:YES];
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

- (IBAction)start:(bool)andGo
{
    [back setHidden:NO];
	[self changeSource:YES];
    [timeToRead setHidden:YES];
    [averageSpeed setHidden:YES];

	[timer invalidate];
	
	marker = 0;
    
    [self updateCounters:!andGo];
	
	[self setToPlay];
	
	if (!andGo) [currentWord setText:@"Ready?"];
}

- (IBAction)prevWord
{
	jumpForward = true;
	if (jumpBack == true) {
		jumpBack = false;
		marker--;
	}
	if (marker > 0) {
		marker--;
		NSString *word = [wordArray objectAtIndex:marker];
		if ([word length] == 0) NSLog(@"*************************BLANK*****BLANK*****BLANK*************************"); //flurry todo - log blank words, with article uuid
		[currentWord setText:word];
        [self updateCounters:YES];
	}
}

- (IBAction)slower
{
	wordsPerMinute = wordsPerMinute - 5;
	rate = 60.0 / wordsPerMinute;
	if ([timer isValid]) [self resetTimer];
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters:YES];
}

- (IBAction)play
{
	if (marker == wordArraySize) {
		[self start:YES];
	}
    [back setHidden:YES];
	[self resetTimer];
    if (marker == 0) startTime = [NSDate date];
	[self setToPause];
}

- (IBAction)pause
{
	if ([timer isValid]) {
        [back setHidden:NO];
		[timer invalidate];
		[self setToPlay];
	}
}

- (IBAction)faster
{
	wordsPerMinute = wordsPerMinute + 5;
	rate = 60.0 / wordsPerMinute;
	if ([timer isValid]) [self resetTimer];
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters:YES];
}

- (IBAction)nextWord
{
	jumpBack = true;
	if (jumpForward == true) {
		jumpForward = false;
		marker++;
	}
	if (marker < wordArraySize) {
		NSString *word = [wordArray objectAtIndex:marker];
		marker++;
		if ([word length] == 0) NSLog(@"*************************BLANK*****BLANK*****BLANK*************************"); //flurry todo - log blank words, with article uuid
		[currentWord setText:word];
        finishTime = [NSDate date];
		[self updateCounters:YES];
	} else if (marker == wordArraySize) {
		[self end];
	}
}

- (IBAction)end
{
	if (marker != wordArraySize) {
		marker = wordArraySize;
		[self updateCounters:NO];
	}
	NSLog(@"Marker: %d - Words: %d", marker, wordArraySize);
	[back setHidden:NO];
	if (sourceEnabled == true) {
		[self changeSource:NO];
	}
	[timer invalidate];
	
	[progress setProgress:1.0];
	
	[self setToPlay];
	
	[currentWord setText:@"Complete!"];
	[timeToRead setHidden:NO];
	[averageSpeed setHidden:NO];
	
	NSTimeInterval difference = [finishTime timeIntervalSinceDate:startTime];
	int minutes = floor(difference / 60);
	int seconds = difference - (minutes * 60);
	NSString *timeToReadResult = [NSString stringWithFormat:@"Time: %d:%02d", minutes, seconds];

	NSString *averageSpeedResult = [NSString stringWithFormat:@"Speed: %.0f wpm", wordArraySize * (60 / difference)];
	if (startTime == NULL) {
		timeToReadResult = @"Time: 0:00";
		averageSpeedResult = @"Speed: 0 wpm";
	}
	[timeToRead setText:timeToReadResult];
	[averageSpeed setText:averageSpeedResult];
	
}

- (void)resetTimer
{
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(nextWord) userInfo:nil repeats:YES];
}

- (void)setToPause
{
	[masterButton setTitle:@"STOP" forState:UIControlStateNormal];
	[masterButton removeTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
	[masterButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToPlay
{
	[masterButton setTitle:@"GO" forState:UIControlStateNormal];
	[masterButton removeTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
	[masterButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeSource:(bool)hide
{
    [source setHidden:hide];
	[timeRemaining setHidden:!hide];
	[words setHidden:!hide];
	[wpmRate setHidden:!hide];
}

- (void)updateButton
{
    UIImage *buttonBackgroundImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonBackgroundImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	
    [back setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [back setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    [source setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    [source setBackgroundImage:buttonBackgroundImageHighlight forState:UIControlStateHighlighted];
    
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
