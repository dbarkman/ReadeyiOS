//
//  WebViewController.m
//  Reader
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize url, webView;

- (id)initWithURL:(NSString *)postURL
{
    self = [super init];
    if (self) {
        url = postURL;
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.url = [self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *newURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
    webView = [[UIWebView alloc] init];
	toolBar = [[UIToolbar alloc] init];

    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		[webView setFrame:CGRectMake(0, 32, self.view.frame.size.height, self.view.frame.size.width - 32)];
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.height, 32)];
    }
	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		[webView setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	}

	[webView setScalesPageToFit:YES];
    [self.view addSubview:webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:newURL]];
	
	toolBar.barStyle = UIBarStyleDefault;
	[toolBar sizeToFit];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
	UIBarButtonItem *flexiableSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
	NSArray *items = [NSArray arrayWithObjects:done, flexiableSpace, back, nil];
	[toolBar setItems:items];
	[self.view addSubview:toolBar];
	
	UIColor *offBlack = [UIColor colorWithRed:31/255.0f green:31/255.0f blue:31/255.0f alpha:1];
	[toolBar setTintColor:offBlack];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		[webView setFrame:CGRectMake(0, 32, self.view.frame.size.height, self.view.frame.size.width - 32)];
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.height, 32)];
    }
	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		[webView setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	}
}

- (IBAction)done
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back
{
	[webView goBack];
}

@end
