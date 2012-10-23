

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Record.h"
#import "RecordDao.h"

@protocol ReminderDetailViewControllerDelegate <NSObject>

- (void)addNotificationwithID:(NSString*)msgid;

@end
@class RestConnection;
@class AppDelegate;
@class DownloadImage;
@interface ReminderDetailViewController : UIViewController {
    IBOutlet UIView *viewMedicationReminder;
    IBOutlet UIView *viewSkipReason;
    IBOutlet UILabel *labelName;
    IBOutlet UILabel *labelCallOut;
    IBOutlet UILabel *labelTimeSchedule;
    IBOutlet UIImageView *imageViewCallOut;
    IBOutlet UIImageView *imageViewTimeSchedule;
    
    IBOutlet UIImageView *imageViewDetail;
    IBOutlet UILabel *labelNameMedication;
    IBOutlet UILabel *labelCallOutMedication;
    IBOutlet UILabel *labelTimeScheduleMedication;
    IBOutlet UIImageView *imageViewCallOutMedication;
    IBOutlet UIImageView *imageViewTimeScheduleMedication;
    /*IBOutlet UIButton *buttonTaken;
    IBOutlet UIButton *buttonTook;
    IBOutlet UIButton *buttonSkip;*/
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnBack2;
    DownloadImage *downloadImage;
    NSString *stringLinkImage;
    
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIActivityIndicatorView *indicatorMedication;
    AppDelegate *appDelegate;
    
    RestConnection *restConnection;
    BOOL isRequesting;
    
    RecordDao *recordDao;
    BOOL isSync;
    UIWebView *webView;
}

@property (nonatomic, retain) NSMutableDictionary *dictReminderDetail;
@property (nonatomic, retain) NSIndexPath *selectIndexPath;
@property (nonatomic, assign) NSInteger iD;
@property (nonatomic, retain) id delegate;
- (IBAction)skip:(id)sender; 
- (IBAction)dissmis:(id)sender; 
- (IBAction)skipReasonAction:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)pressBack:(id)sender;
- (void)hideBackBtn;
- (void)updateHistory:(NSMutableDictionary*)datadict;
- (NSString*)convertDateFromFloatString2:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
@end
