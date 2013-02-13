//
//  WebViewController.h
//  Reader
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
{
	UIToolbar *toolBar;
}
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIWebView *webView;

- (id)initWithURL:(NSString *)postURL;

@end
