

#import <UIKit/UIKit.h>
#import "AddReminderTypeView.h"
#import "Record.h"
#import "RecordDao.h"

//@class DownloadImage;
@class RestConnection;
@class AppDelegate;
@interface SetupReminderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddReminderTypeViewDelegate, UIActionSheetDelegate> {
    IBOutlet UITableView *tableView;
    AddReminderTypeView* addReminderTypeView;
    IBOutlet UIImageView *imageViewAmoundReminderBG;
    IBOutlet UIButton *bottomAction; //delete, done button
    IBOutlet UIButton *termOfUse;
    IBOutlet UIView *viewAddReminder;
    UIView *bgView;
    //IBOutlet UIButton *buttonShowYourReminder;
    NSMutableArray *arrayReminders;
    NSMutableArray *arrayReminderByDeleveryDate;
    NSDictionary *dictAReminder;
    BOOL isDeleteCell;
    BOOL isSaving;
    BOOL isShowAddReminderTypeView;
    IBOutlet UIActivityIndicatorView *indicator;
    //DownloadImage *downLoadImage;
    AppDelegate *appDelegate;
    RestConnection *restConnection;
    NSInteger index;
    NSInteger selectedIndex;

    BOOL active;
    
    RecordDao *recordDao;
    NSInteger iD;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *bottomAction;
@property (nonatomic, retain) IBOutlet UIButton *termOfUse;
@property (nonatomic, assign) BOOL isShowAddReminderTypeView;

- (IBAction)toggleEdit:(id)sender;
- (IBAction)pressTermOfUse;
- (IBAction)pressHome;
- (IBAction)pressAdd:(UIButton *)sender;
- (IBAction)showAddForm:(id)sender;
@property BOOL isDeleteCell;
- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
- (void)loadData;
- (void)reloadData;
- (IBAction)changeReminderStatus:(id)sender;
- (void)writeDataToTextFile;
- (NSString *)getProperty: (NSString *)key forData: (NSDictionary *)dataList;
- (void)saveSetupReminderToDatabase;
@end
