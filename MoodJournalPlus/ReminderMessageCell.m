//
//  ReminderMessageCell.m
//  MoodJournalPlus
//
//  Created by luan on 10/12/12.
//  Copyright (c) 2012 CNCSoft. All rights reserved.
//

#import "ReminderMessageCell.h"

@implementation ReminderMessageCell
@synthesize tit;
@synthesize textMessage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];  
    return YES;
}
- (void)dealloc {
    [tit release];
    [textMessage release];
    [super dealloc];
}
@end
