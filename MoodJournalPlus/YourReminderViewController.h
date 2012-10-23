

#import <UIKit/UIKit.h>
#import "Record.h"
#import "RecordDao.h"

//@class DownloadImage;
@class AppDelegate;
@class RestConnection;
@interface YourReminderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *labelMotivation;
    IBOutlet UIActivityIndicatorView *indicator;
    NSMutableArray *arrayReminders;
    NSMutableArray *arrayReminderByDeleveryDate;
    NSMutableDictionary *dict;
	NSMutableArray *keys;
    AppDelegate *appDelegate;
    RestConnection *restConnection;
    IBOutlet UILabel *labelNoRecord;
    //DownloadImage *downLoadImage;
    BOOL gotoDetail;
    BOOL finishLoading; //equal to TRUE if reminders is finished loading (to prevent user from touching History button before all reminder is load.
    BOOL isLoading;
    
    RecordDao *recordDao;
    NSMutableArray *arrayUpcomming;
    
    IBOutlet UILabel *labelBanner;
    IBOutlet UIButton *buttonBanner;
}
- (NSMutableArray*)sortReminderByDeleveryDate;
- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
//footer action
- (IBAction)pressTermOfUse:(id)sender;
- (IBAction)pressMoreOptions:(id)sender;
- (IBAction)pressHistory:(id)sender;
- (id)getFirstReminder; 
- (void)requestData;
- (void)reloadData;
- (void)reloadData3;
- (void)reloadTableView:(NSIndexPath*)indexPath;
- (void)saveYourReminderToDatabase;
- (void)showDetailReminder;

- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)syncButtonPressed:(id)sender;
- (IBAction)showMovitationView:(id)sender;
- (void)reloadBanner;
@end
