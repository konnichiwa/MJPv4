

#import <UIKit/UIKit.h>
@class AppDelegate;
@interface SelectDayViewController : UIViewController {
    IBOutlet UITableView *tableView;
    NSMutableArray *arrayDate;
    NSMutableArray *arrayTimeSet;
    IBOutlet UIDatePicker *pickerView;
    //IBOutlet UIView *viewSetTime;
    NSString *stringDate;
    AppDelegate *appDelegate;
    NSMutableArray *arrayCheck;
}

- (IBAction)pressBack:(id)sender;
- (IBAction)done;
@end
