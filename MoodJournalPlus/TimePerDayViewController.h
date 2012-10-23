

#import <UIKit/UIKit.h>
@class AppDelegate;
@interface TimePerDayViewController : UIViewController {
    IBOutlet UITableView *tableView;
    IBOutlet UIView *viewDatePicker;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIView *viewShadowMinute;
    IBOutlet UIButton *bottomAction;
    NSMutableArray *arrayTimePerDay;
    NSMutableArray *arrayTime;
    NSIndexPath *indexPathSelected;
    NSString *stringDate;
    NSMutableArray *arrayDate;
    NSString *reminderTime;
    AppDelegate *appDelegate;
    
}
@property (nonatomic, assign) BOOL allowMultipleTimePerDay;
@property (nonatomic, retain) NSString *timePerDay;
@property (nonatomic, assign) BOOL isDeleteCell;
- (IBAction)toggleEdit:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)setDate:(id)sender;
- (IBAction)pressBack:(id)sender;
- (IBAction)done:(id)sender;

@end
