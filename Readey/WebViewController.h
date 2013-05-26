//
//  WebViewController.h
//  Reader
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
{
	UIToolbar *toolBar;
}
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIWebView *webView;

- (id)initWithURL:(NSString *)postURL;

@end
