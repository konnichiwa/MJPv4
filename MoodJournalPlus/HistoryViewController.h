

#import <UIKit/UIKit.h>
@class RestConnection;
@class AppDelegate;
//@class DownloadImage;
@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
    IBOutlet UIActivityIndicatorView *indicator;
    UIView *bgView;
    NSMutableArray *dataList;
    NSMutableArray *arrayDay;
    NSMutableArray *arrayReminders;
    NSMutableDictionary *dict;
	NSMutableArray *keys;
    int countDay;
    BOOL isLoading;
    
    AppDelegate *appDelegate;
    //RestConnection *restConnection;
    //DownloadImage *downLoadImage;
    double startdate;
    double enddate;
    NSMutableArray *arrayDateSelected;
    NSMutableArray *arrayRestConnection;//1405
    BOOL theFirst;
    
    IBOutlet UILabel *labelBanner;
    IBOutlet UIButton *buttonBanner;
}

- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
- (NSString*)convertDateFromFloatString2:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
- (void)sortReminderByDeleveryDate;
- (NSMutableArray*)findDataForTableView:(NSString*)date;

- (IBAction)pressTermOfUse:(id)sender;
- (IBAction)pressMoreOptions:(id)sender;
- (IBAction)pressHome:(id)sender;
- (void)requestData;
- (void)reloadBanner;
- (IBAction)showMovitationView:(id)sender;
@end
