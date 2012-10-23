

#import <UIKit/UIKit.h>
#import "RemindeMeView.h"

@class AppDelegate;
@interface FrequencyViewController : UIViewController <RemindeMeViewDelegate>{
    IBOutlet UITableView *tableView;
    NSArray *arrayFrequency;
    
    AppDelegate *appDelegate;
    BOOL allowMultipleTimePerDay;
}
@property (nonatomic, assign) BOOL isFrequency;
@property (nonatomic, assign) ReminderType reminderType;

- (IBAction)pressBack:(id)sender;
@end
