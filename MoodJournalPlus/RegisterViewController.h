

#import <UIKit/UIKit.h>
@class AppDelegate;
@class RestConnection;
@interface RegisterViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITextField *textFieldUserID;
    IBOutlet UITextField *textFieldPassword;
    IBOutlet UITextField *textFieldPassConfirm;
    IBOutlet UIButton *buttonCheckbox;
    IBOutlet UIImageView *imageViewBG;
    IBOutlet UITextField *textFieldAnwser;
    IBOutlet UILabel *labelQuestion;
    IBOutlet UIActivityIndicatorView *indicator;
    NSString *stringQuestion;
    NSString *stringAnswer;
    NSArray *arraySecurityQuestion;
    BOOL isCheckBox;
    BOOL isSave;
    BOOL isShowSecurityQuestionView;
    BOOL isValidData;
    BOOL isChecking;
    NSInteger index;
    AppDelegate *appDelegate;    
    RestConnection *restConnection;
    NSString *b64UserID;
    NSString *b64Password;
    
}

- (IBAction)hiddenKeyboard:(id)sender;
- (IBAction)checkBox:(id)sender;
- (IBAction)pressBack:(id)sender;
//- (IBAction)chooseAvatar:(id)sender;
- (IBAction)setSecurityQuestion:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)pressTermOfUse:(id)sender;
- (IBAction)pressPrivacy:(id)sender;
- (IBAction)answerEditor:(id)sender;
- (IBAction)endAnswerEditor:(id)sender;
- (NSString*)createJSON;
//Action of security question view
//- (IBAction)saveSecurityQuestion:(id)sender;
- (IBAction)checkUserID:(id)sender;
@end
