

#import <UIKit/UIKit.h>


//@class DownloadImage;
@class AppDelegate;
@interface ReminderLogViewController : UIViewController {
    IBOutlet UIImageView *imageViewCallOut;
    IBOutlet UILabel *labelName;
    IBOutlet UILabel *labelNameRefil;
    IBOutlet UILabel *labelContent;
    IBOutlet UIImageView *imageViewScheduleTime;
    IBOutlet UILabel *labelScheduleTime;
    IBOutlet UIImageView *imageViewStatus;
    IBOutlet UILabel *labelStatus;
    AppDelegate *appDelegate;
    IBOutlet UIView *viewMedication;
    IBOutlet UIImageView *imageViewCallOutMedication;
    IBOutlet UILabel *labelContentMedication;
    //IBOutlet UILabel *labelAmountMedication;
    IBOutlet UIImageView *imageViewStatusMedication;
    IBOutlet UILabel *labelStatusMedication;
    IBOutlet UIImageView *imageViewScheduleMedication;
    IBOutlet UILabel *labelScheduleMedication;
    IBOutlet UIImageView *imageViewReminderPhoto;
    //DownloadImage *downloadImage;
    NSString *stringLinkImage;
}
@property (nonatomic, retain) NSDictionary *dictReminderDetail;
- (IBAction)pressBack:(id)sender;
- (IBAction)pressTermOfUse:(id)sender;
- (IBAction)pressMoreOptions:(id)sender;

@end
