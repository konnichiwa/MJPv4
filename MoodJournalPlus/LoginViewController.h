

#import <UIKit/UIKit.h>

@class AppDelegate;
@class RestConnection;

@interface LoginViewController : UIViewController <UITextFieldDelegate>{
    //control of LoginView
    IBOutlet UITextField *textFieldUserName;
    IBOutlet UITextField *textFieldPassword;
    IBOutlet UIButton *buttonRemember;
    IBOutlet UIActivityIndicatorView *indicator; 
    IBOutlet UILabel *welcomeBack;
    //control of LoginRememberView
    IBOutlet UILabel *labelUserName;
    AppDelegate *appDelegate;
    RestConnection *restConnection;
    BOOL isRememberPassword;
    BOOL isLogin;
    BOOL isVerifyAccount;
    NSInteger firstLogin;
    NSInteger index;
}
@property (nonatomic, retain) IBOutlet UITextField *textFieldUserName;
- (IBAction)hiddenKeyboard:(id)sender;
- (IBAction)rememberPassword:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)registerAccount:(id)sender;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)setHighlight:(id)sender;
- (void)gotoHome;
- (void)checkForInternetConnection;
@end
