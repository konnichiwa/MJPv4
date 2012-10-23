

#import "SetupAReminderCell.h"

@implementation SetupAReminderCell
@synthesize labelReminderParam, labelReminderParamValue;
@synthesize imageViewAccessory, imageViewItem;
@synthesize buttonTimeSet;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    NSLog(@"a reminder cell");
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc {
    [super dealloc];
    [labelReminderParam release];
    //[labelReminderParamValue release];
    //[imageViewAccessory release];
    [imageViewItem release];
}
@end
