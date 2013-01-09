//
//  ReadeyViewController.m
//  Readey
//
//  Created by David Barkman on 1/8/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "ReadeyViewController.h"

@interface ReadeyViewController ()

@end

@implementation ReadeyViewController

@synthesize marker, wordArray, wordArraySize;
@synthesize rate, wordsPerMinute, timer, start, finish;

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
	
	NSString *article = @"SUMMARY: Until now, the mobile revolution has been about squeezing the desktop internet onto portable devices. Entrepreneur Edward Aten says the real revolution for smartphones is about fulfilling a whole new set of needs that people have in their daily lives.   It was a banner year for mobile in 2012. Smartphone use eclipsed that of feature phones in the U.S., and time spent on mobile devices jumped 40 percent. And yet our expectations for mobile are still an order of magnitude too small. The truth is, many of us remain blind to the possibilities of the devices we carry in our pockets because we continue to view the future of mobile in the context of the web.   Mobile is not an iterative step for the web, but a complete revolution. So instead of asking ourselves how we can adapt web-based stores to our smartphones, we should be asking how we can use unlimited access to information to help us when we are in actual stores. The full potential of the mobile revolution won’t be realized until we build the tools that make every moment of our lives better.   The internet squeezed onto mobile devices:   It’s understandable that we use the web as the baseline for measuring mobile, especially since many of our most widely used apps and services originated online – email, text, maps, Twitter, Facebook, Amazon and so on. The comparison has worked until now because we’ve spent our first years with smartphones reformatting the desktop experience of the web to fit into our pockets.   Today the web itself  is the product of decades of adapting the real world onto the connected desktop. First we ported over letters (email) and posters (websites). Then we moved what we could of traditional businesses online to the large screen perched on our desks: Bookstores and record stores became (literally) Amazon.com and iTunes; travel agents became Kayak.com and Yelp.com.   Since smartphones have brought computing power and an internet connection to our pockets, naturally we want those tools everywhere we go. But porting these advancements to our phones is only a pre-game to the real mobile revolution: when connectivity reshapes our minute-by-minute lives.   The offline opportunity:   Opportunity is everywhere: The offline world is filled with friction, inefficiency, incomplete information, tedium and excess capacity. We feel it all the time. Waiting for elevators. Waiting for delivery drivers. Going across town only to find an empty bar. Forgetting the name of the person you just met.   These problems are so frequent and inherently human we are often blind to them. But for almost every problem we encounter, relief will be found in the same place: The device we carry with us. We don’t need to log in. Sensors minimize the information input. Smart assistants and voice recognition allow hand’s-free use and allow the least technically capable among us to use their deepest, richest features.   Last year saw the first mass implementations of phones making what used to be our offline lives better with companies like Uber and HotelTonight, but 2013 will be the year in which we start looking to our devices to scratch our every itch – for companionship, entertainment and much more.";//   Why now?   A number of these ideas have been around for a long time, but 2013 will be our first chance to build many of these new companies.   When Amazon.com started in 1994, less than 10 percent of U.S. adults were online. But even though that small segment of the population was spread around the country, everyone used the product in the same way whether the user was in Dubuque, Detroit or Dallas. Everyone hit the same website, bought the same things and was plugged into the same distribution network. In its infancy, Amazon only needed a tiny fraction of the country to use its services.   The comparison today with Uber, the real-time limo service, almost makes itself. Uber instantly pairs available drivers and cars with demand for rides. Crucially, Uber needs a critical mass of both supply and demand on its platform in the same geographical area, down to the same neighborhoods and streets, and needs to be able to update and match them in real time based on their current locations – a task nearly impossible to accomplish at scale on desktops or laptops. There are several forces beyond raw adoption numbers though that enable Uber’s success:   Smartphones free us from our desks. When we have problems, questions or desires, we don’t need to return to our homes or offices to satiate them; we can address them on the spot.   Touchscreens, Android and iOS are amazingly simple to use. Not only do people have the technology readily available to them, but even the least technically savvy can (and do) use it.   Apps are simple, elegant problem solvers. Small, beautiful, and easy-to-use, the best apps are easily understood in seconds.   This is the year these trends will reach critical mass in almost every major market in the US. The result will be that more great companies will be started, gain meaningful traction and drive investment. More startups will get more tries at solving problems, and a virtuous cycle will accelerate the trends.   Bringing the offline world online poses unique hurdles [and rewards:   While some problems are easy to identify they may be difficult to solve. Unlike many of the first internet companies, the real world has legacy industries with entrenched lobbies, distribution providers or regulations. Many require real infrastructure that needs to be acquired, integrated with or leased. In the offline world, scale is often much harder than simply spinning up additional servers.   On the other hand, many of these new companies will become natural monopolies – difficult to overthrow once they achieve scale, lock up resources within their systems and start generating significant cash. Many are adaptations or improvements of current businesses, but given the inability of incumbents to design, develop and deploy revolutionary software, we can expect many to be upset by startups.   Looking to the future:   Unlike any technology we have ever seen, mobile has the opportunity to improve our minute-by-minute lives, wherever we are. While there are unique perils to the offline world, the significant rewards to those that build these new companies more than offset the risk.   Companies like Uber and HotelTonight are just the tip of the iceberg. Square isn’t just revolutionizing payments, but the experience of paying for things in real life. A company like Highlight will eventually be a real-time, in-person LinkedIn that gives us context, history and information for all of our encounters.   Mobile isn’t a portal to the internet we know today, but a gateway to build world-changing companies that will upend entrenched incumbents and exponentially recast even the most bullish of mobile expectations.   Edward Aten is a designer and entrepreneur. He is the founder and CEO of CopThis and previously founded Swift.fm. Follow him on Twitter at @aten.";
		
	NSArray *tempArray = [article componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	wordArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
	wordArraySize = [wordArray count];
	
	wordsPerMinute = 200;
	rate = 60.0 / wordsPerMinute;
	
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters];
}

- (void)updateCounters
{
	float timeRemain = (wordArraySize - marker) * rate;
	float minutes = floor(timeRemain / 60);
	float seconds = timeRemain - minutes * 60;
	if (minutes > 0) {
		[timeRemaining setText:[NSString stringWithFormat:@"%.0f mins %.2f secs", minutes, seconds]];
	} else {
		[timeRemaining setText:[NSString stringWithFormat:@"%.2f secs", seconds]];
	}
	[words setText:[NSString stringWithFormat:@"%d words", wordArraySize - marker]];
    [progress setProgress:(1.0 / wordArraySize) * marker animated:YES];
}

- (IBAction)nextWord:(id)sender
{
	if (marker < wordArraySize) {
		int wordLength = 0;
		NSString *word = @"";
		while (wordLength == 0) {
			word = [wordArray objectAtIndex:marker];
			wordLength = [word length];
			marker++;
		}
		[currentWord setText:word];
        finish = [NSDate date];
		[self updateCounters];
	} else if (marker == wordArraySize) {
        [back setHidden:NO];
		[timer invalidate];
		
		[self setToRestart];
		[self setToResume];
        
        [currentWord setText:@"Complete!"];
        [timeToRead setHidden:NO];
        [averageSpeed setHidden:NO];

        NSTimeInterval difference = [finish timeIntervalSinceDate:start];
        [timeToRead setText:[NSString stringWithFormat:@"Time to Read: %.2f", difference]];
        [averageSpeed setText:[NSString stringWithFormat:@"Average Speed: %.0f wpm", wordArraySize * (60 / difference)]];
	}
}

- (IBAction)prevWord:(id)sender
{
	if (marker > 0) {
		int wordLength = 0;
		NSString *word = @"";
		while (wordLength == 0) {
			word = [wordArray objectAtIndex:marker];
			wordLength = [word length];
			marker--;
		}
		[currentWord setText:word];
        [self updateCounters];
	}
}

- (IBAction)faster:(id)sender
{
	wordsPerMinute = wordsPerMinute + 5;
	rate = 60.0 / wordsPerMinute;
	if ([timer isValid]) [self resetTimer];
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters];
}

- (IBAction)slower:(id)sender
{
	wordsPerMinute = wordsPerMinute - 5;
	rate = 60.0 / wordsPerMinute;
	if ([timer isValid]) [self resetTimer];
	[wpmRate setText:[NSString stringWithFormat:@"%.0f wpm", wordsPerMinute]];
	[self updateCounters];
}

- (void)resetTimer
{
	[timer invalidate];
	timer = [NSTimer scheduledTimerWithTimeInterval:rate
											 target:self
										   selector:@selector(nextWord:)
										   userInfo:nil
											repeats:YES];
}

- (IBAction)startReading:(id)sender
{
    [back setHidden:YES];
    [timeToRead setHidden:YES];
    [averageSpeed setHidden:YES];
	[self resetTimer];
    start = [NSDate date];
	[self setToRestart];
	[self setToPause];
}

- (IBAction)pause:(id)sender
{
	if ([timer isValid]) {
        [back setHidden:NO];
		[timer invalidate];
		[self setToResume];
	}
}

- (IBAction)resume:(id)sender
{
    [back setHidden:YES];
	[self resetTimer];
	[self setToPause];
}

- (IBAction)restart:(id)sender
{
    [back setHidden:NO];
	[timer invalidate];
	
	marker = 0;
    
    [self updateCounters];
	
	[self setToStart];
	[self setToPause];
	
	[currentWord setText:@"Ready?"];
}

- (void)setToPause
{
	[pause setTitle:@"Pause" forState:UIControlStateNormal];
	[pause removeTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
	[pause addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToResume
{
	[pause setTitle:@"Resume" forState:UIControlStateNormal];
	[pause removeTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
	[pause addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToStart
{
	[startReading setTitle:@"Start" forState:UIControlStateNormal];
	[startReading removeTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
	[startReading addTarget:self action:@selector(startReading:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setToRestart
{
	[startReading setTitle:@"Restart" forState:UIControlStateNormal];
	[startReading removeTarget:self action:@selector(startReading:) forControlEvents:UIControlEventTouchUpInside];
	[startReading addTarget:self action:@selector(restart:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateButton
{
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [startReading setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startReading setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [pause setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [pause setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [back setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [back setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [prevWordBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [prevWordBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [nextWordBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [nextWordBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [fasterBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [fasterBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [slowerBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [slowerBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

@end
