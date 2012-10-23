

#import <UIKit/UIKit.h>
@class AppDelegate;
@class RestConnection;

@interface AccountSettingViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate>{
    IBOutlet UITextField *textFieldUserID;
    IBOutlet UITextField *textFieldPassword;
    IBOutlet UILabel *labelSecurityQuestion;
    IBOutlet UITextField *textFieldEmail;
    IBOutlet UILabel *labelGender;
    IBOutlet UITextField *textfieldAge;
    IBOutlet UILabel *labelMaterialStatus;
    UIActionSheet *asGender;
    UIActionSheet *asMaterialStatus;
    UIActionSheet *asAge;
    //Security Question View
    IBOutlet UIView *viewSecurityQuestion;
    IBOutlet UITextField *textFieldAnwser;
    IBOutlet UITextField *textFieldQuestion;
    IBOutlet UIActivityIndicatorView *indicator;
    NSMutableDictionary *dataDict;
    
    NSArray *arraySecurityQuestion;
    BOOL isSaving;
    BOOL isShowSecurityQuestionView;
    
    NSString *stringQuestion;
    NSString *stringAnswer;
    BOOL isCheck;
    BOOL isSave;
    NSInteger index;
    NSInteger numConnection;
    AppDelegate *appDelegate;
    RestConnection *restConnection;
    
}

//- (NSString *)createJSON;
- (IBAction)setSecurityQuestion:(id)sender;
- (IBAction)saveChange:(id)sender;
- (IBAction)hiddenKeyboard:(id)sender;
- (IBAction)pressBack:(id)sender;
- (IBAction)pressChangeGender:(id)sender;
- (IBAction)pressChangeMaterialStatus:(id)sender;
//Action of security question view
- (IBAction)saveSecurityQuestion:(id)sender;
- (IBAction)ageEditor:(id)sender;
- (IBAction)exitAgeEditor:(id)sender;
- (IBAction)pressChangePassword:(id)sender;
- (IBAction)showQuestionList:(id)sender;
- (IBAction)clickToEdit:(id)sender;
- (IBAction)answerEditor:(id)sender;
- (IBAction)editEmail;//simulate touch to email field
- (IBAction)editAge;//simulate touch to age field
- (IBAction)pressChangeAge:(id)sender;
@end
