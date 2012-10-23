

#import <UIKit/UIKit.h>
@class AppDelegate;
@interface FistRegisterViewController : UIViewController{
    IBOutlet UILabel *labelGreeting;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
-(IBAction)addFirstMedication:(id)sender;
@end
