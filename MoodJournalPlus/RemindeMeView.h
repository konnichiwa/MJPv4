
#import <UIKit/UIKit.h>

@protocol RemindeMeViewDelegate <NSObject>
@required 
-(void)selectRemindeMe:(NSString*)time;
@end

@interface RemindeMeView : UIView <UITextFieldDelegate, UIPickerViewDelegate>{
    IBOutlet UIView *viewBG;
    IBOutlet UITextField *textFieldInterval;
    IBOutlet UITextField *textFieldEvery;
    IBOutlet UIPickerView *pickerView;
    
    NSArray *arrayTimeInterval;
    NSArray *arrayEvery;
    BOOL selectInterval;
}
@property (nonatomic, assign) id <RemindeMeViewDelegate> delegate;
@property (nonatomic, assign) BOOL isRemindeMeInAppointment;

- (void)setUpView;
- (IBAction)hiddenKeyboard:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
@end
