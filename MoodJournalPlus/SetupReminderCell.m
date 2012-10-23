

#import "SetupReminderCell.h"

@implementation SetupReminderCell
@synthesize labelDate, labelName,labelTime;
@synthesize switchActive;
@synthesize imageView;
@synthesize tableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    NSLog(@"switch active");
    //switchActive.onTintColor = [UIColor redColor];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [super dealloc];
    [labelTime release];
    [labelDate release];
    [labelName release];
    //[switchActive release];
    //[imageView release];
}
@end
