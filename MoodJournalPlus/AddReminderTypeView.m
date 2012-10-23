//
//  AddReminderTypeView.m
//  MoodJournalPlus
//
//  Created by Java-Dive on 1/1/12.
//  Copyright (c) Java-Dive Inc. 2009. All rights reserved.
//

#import "AddReminderTypeView.h"

@implementation AddReminderTypeView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)selectReminderType:(id)sender {
    int tag = [sender tag];
    switch (tag) {
        case 0:
            if (self.delegate != nil && [delegate respondsToSelector:@selector(selectRemiderType:)]) {
                [delegate selectRemiderType:kMedication];
            }
            break;
        case 1:
            if (self.delegate != nil && [delegate respondsToSelector:@selector(selectRemiderType:)]) {
                [delegate selectRemiderType:kPrescriptionFill];
            }
            break;
        case 2:
            if (self.delegate != nil && [delegate respondsToSelector:@selector(selectRemiderType:)]) {
                [delegate selectRemiderType:kAppointment];
            }
            break;
        case 3:
            if (self.delegate != nil && [delegate respondsToSelector:@selector(selectRemiderType:)]) {
                [delegate selectRemiderType:kVital];
            }
            break;
        default:
            break;
    }
}

@end
