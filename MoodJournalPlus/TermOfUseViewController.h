
#import <UIKit/UIKit.h>
#define kLINKPOLICY @"http://50.19.213.37/controlhandler.do?pageid=1053&wapid=83&userid=122"
#define kLINKLEGAL @"http://50.19.213.37/controlhandler.do?pageid=1052&wapid=83&userid=122"
#define kLINKCOPYRIGHT @"http://50.19.213.37/controlhandler.do?pageid=1051&wapid=83&userid=122"
#define kLINKCONTACT @"http://50.19.213.37/controlhandler.do?pageid=1050&wapid=83&userid=122"
#define kLINKABOUT @"http://50.19.213.37/controlhandler.do?pageid=1049&wapid=83&userid=122"
//#define kLINKTERMOFUSE @"http://99.19.199.102:8080/ogROOT/dev/app/signup.html"
@interface TermOfUseViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIView *viewCommon;
    IBOutlet UILabel *labelHeader;
    //IBOutlet UILabel *labelLoading;
    IBOutlet UIActivityIndicatorView *indicator;
    NSInteger termID;
}
@property NSInteger termID;
-(IBAction)pressBack:(id)sender;
-(IBAction)pressDetail:(UIButton *)sender;
- (void)loadDetail:(NSInteger) tID;


@end