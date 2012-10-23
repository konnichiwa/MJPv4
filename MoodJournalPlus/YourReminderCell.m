

#import "YourReminderCell.h"

@implementation YourReminderCell
@synthesize labelDate, labelTime, labelName;
@synthesize imageViewIcon;
@synthesize clockIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    NSLog(@"%@",reuseIdentifier);
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [super dealloc];
    [labelDate release];
    [labelName release];
    [labelTime release];
    [imageViewIcon release];
    [clockIcon release];
}
@end
