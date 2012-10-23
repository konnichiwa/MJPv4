

#import <UIKit/UIKit.h>
@class AppDelegate;
@class RestConnection;

@interface ChangePassViewController : UIViewController <UITextFieldDelegate,UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>{
    IBOutlet UITextField *textFieldOldPass;
    IBOutlet UITextField *textFieldNewPass;
    IBOutlet UITextField *textFieldConfirm;
    
    IBOutlet UIActivityIndicatorView *indicator;
    BOOL isCheck;
    BOOL isSave;
    NSInteger index;
    NSInteger numConnection;
    AppDelegate *appDelegate;
    RestConnection *restConnection;
    
}
- (IBAction)saveChange:(id)sender;
- (IBAction)hiddenKeyboard:(id)sender;
- (IBAction)pressBack:(id)sender;

@end
