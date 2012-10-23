

#import <UIKit/UIKit.h>
@class RestConnection;
@class AppDelegate;
@interface ForgotPassViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>{
    NSString *userID;
    IBOutlet UILabel *labelQuestion;
    IBOutlet UITextField *textAnswer;
    IBOutlet UILabel *labelUsername;
    IBOutlet UILabel *labelPassword;
    IBOutlet UIView *returnLoginView;
    IBOutlet UIActivityIndicatorView *indicator;
    UITextField *textUserId;
    RestConnection *restConnection;
    AppDelegate *appDelegate;
    NSInteger index;
    BOOL isSaving;
    BOOL submitDeviceID;
}
@property (nonatomic, retain) NSString *userID;
- (IBAction)submitQuestion:(id)sender;
- (IBAction)resignView;
- (IBAction)returnSignin;
- (IBAction)pressBack;
@end
