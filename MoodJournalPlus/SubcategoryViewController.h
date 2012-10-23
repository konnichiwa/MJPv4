

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@class RestConnection;
@class AppDelegate;
@interface SubcategoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>{
    IBOutlet UITableView *tableView;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITextField *textFieldAddSubcategory;
    IBOutlet UIView *viewAddForm;
    UIActionSheet *actionSheet;
    //NSMutableArray *arraySubcategory;
    IBOutlet UIActivityIndicatorView *indicator;
    NSMutableDictionary *dict;
	NSMutableArray *keys;
    BOOL isHaveTitle; //detect Reminder Type: Yes --> Medication & Refill, No --> Appointment & Vitals
    BOOL finishLoad;
    AppDelegate *appDelegate;
    RestConnection *restConnection;
}
@property (nonatomic, assign) ReminderType reminderType; 

- (void)resetTableViewWithArray:(NSMutableArray*)array;
- (void)searchCategorybyName:(NSString*)name;
- (IBAction)addMedication;
- (IBAction)pressBack:(id)sender;
- (IBAction)pressCancelAdd:(id)sender;
- (IBAction)pressShowAddView:(id)sender;
- (IBAction)beginPressSubName:(id)sender;
- (IBAction)endPressSubName:(id)sender;
@end
