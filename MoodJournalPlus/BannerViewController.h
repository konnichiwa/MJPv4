

#import <UIKit/UIKit.h>

@interface BannerViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *indicator;
}
@property (nonatomic, retain) NSString *link;

- (IBAction)back:(id)sender;
@end
