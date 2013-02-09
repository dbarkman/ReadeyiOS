//
//  WebViewController.h
//  Reader
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIWebView *webView;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle;

@end
