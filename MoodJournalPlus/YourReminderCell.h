

#import <UIKit/UIKit.h>

@interface YourReminderCell : UITableViewCell {
    IBOutlet UILabel *labelName;
    IBOutlet UILabel *labelDate;
    IBOutlet UILabel *labelTime;
    IBOutlet UIImageView *imageViewIcon;
    IBOutlet UIImageView *clockIcon;
}
@property (nonatomic, retain) UILabel *labelName;
@property (nonatomic, retain) UILabel *labelDate;
@property (nonatomic, retain) UILabel *labelTime;
@property (nonatomic, retain) UIImageView *imageViewIcon;
@property (nonatomic, retain) UIImageView *clockIcon;
@end
