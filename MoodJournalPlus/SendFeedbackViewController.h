

#import <UIKit/UIKit.h>
#define kFeedbackLink @"http://50.19.213.37/controlhandler.do?pageid=1044&wapid=82&userid=121"
@interface SendFeedbackViewController : UIViewController
<UIWebViewDelegate>
{
    IBOutlet UIButton *btnOpt1;
    IBOutlet UIButton *btnOpt2;
    IBOutlet UIButton *btnOpt3;
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIWebView *webView;
    IBOutlet UILabel *labelLoading;
    NSInteger chooseID;
}
- (IBAction)pressSendFeedback:(id)sender;
- (IBAction)pressCheckBox:(UIButton *)sender;
- (IBAction)pressBack;
@end
