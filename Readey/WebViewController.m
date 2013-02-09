//
//  WebViewController.m
//  Reader
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize url = _url, webView = _webView;

UIToolbar *toolBar;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle
{
    self = [super init];
    if (self) {
        _url = postURL;
        self.title = postTitle;
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.url = [self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *newURL = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:newURL]];
	
	toolBar = [[UIToolbar alloc] init];
	toolBar.barStyle = UIBarStyleDefault;
	[toolBar sizeToFit];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
	NSArray *items = [NSArray arrayWithObjects:done, nil];
	[toolBar setItems:items];
	[self.view addSubview:toolBar];
	
	NSData *calmingBlueData = [[NSUserDefaults standardUserDefaults] objectForKey:@"calmingBlue"];
	UIColor *calmingBlue = [NSKeyedUnarchiver unarchiveObjectWithData:calmingBlueData];
	
	[toolBar setTintColor:calmingBlue];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		[_webView setFrame:CGRectMake(0, 32, self.view.frame.size.height, self.view.frame.size.width - 32)];
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.height, 32)];
    }
	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		[_webView setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
		[toolBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	}
}

- (IBAction)done
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
