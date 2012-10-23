
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//#import "MedicationStrengthView.h"
#import "RemindeMeView.h"
#import "SelectStockImageView.h"

@class RestConnection;
@class DownloadImage;

@interface SetupAReminderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, RemindeMeViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    IBOutlet UITableView *tableView;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIView *viewDatePicker;
    IBOutlet UILabel *labelTitle;
    NSMutableArray *arrayParamReminder;
    NSMutableDictionary *dictParamValueReminder;
    IBOutlet UIActivityIndicatorView *indicator;
    NSIndexPath *currentEditIndex;
    AppDelegate *appDelegate;
    BOOL isStartDate;
    BOOL isDate;
    BOOL isVitalTime;
    BOOL isMedicationTime;
    BOOL isSaving;
    BOOL pressedSave;
    NSString *stringDate;
    
    NSDate *startDate;
    NSDate *endDate;
    BOOL firstTimeSignin;
    NSString *strRefillDate;
    RestConnection *restConnection;
    NSInteger index;
    NSInteger selectedIndex;
    DownloadImage *downLoadImage;
    NSString *stringLinkImage;
    BOOL hasRefillDate;
    BOOL isMedication;
    BOOL gotoTimePerDay;//after choose daily, popup time per day.
    IBOutlet UIScrollView *scrollView;
    UITextField *currentTextField;
    NSString *yourMessage;
    NSMutableArray *folderCheckArray;
}
@property (retain, nonatomic) IBOutlet UIView *viewPickerImage;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerImage;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableDictionary *dictReminderDetail;
@property (nonatomic, assign) ReminderType reminderType;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableDictionary *dictParamValueReminder;
@property (nonatomic, retain) NSMutableArray *arrayParamReminder;
@property (nonatomic, assign) BOOL allowMultipleTimePerDay;
@property (nonatomic, assign) BOOL isShowImageStock;
@property (nonatomic, assign) BOOL firstTimeSignin;
@property (nonatomic, assign) BOOL isUpdateReminder;
@property (nonatomic, assign) BOOL gotoTimePerDay;
@property (nonatomic, retain) NSIndexPath *currentEditIndex;
@property (nonatomic, assign) NSInteger iD;
@property (nonatomic, retain) NSMutableArray *pharmacyList;
- (IBAction)dismissPickerImage:(id)sender;

- (IBAction)changeValueDatePicker:(id)sender;
- (IBAction)setDate:(id)sender;
- (IBAction)dismissViewDatePicker:(id)sender;
- (IBAction)pressBack:(id)sender;
//1402
- (void)callTimePerDayVC;
- (void)setUpMedicationReminder:(NSMutableDictionary*)baseTemplate;
- (void)setUpRefillReminder:(NSMutableDictionary*)baseTemplate;
- (void)setUpRimider:(NSMutableDictionary*)baseTemplate;
- (NSString*)converTimeToMilisecond:(NSDate*)date;
- (NSString*)timezone;
- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
- (void)selectStockImage:(NSString *)image;
@end
