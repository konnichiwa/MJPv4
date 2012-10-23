

#import "RemindeMeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RemindeMeView
@synthesize delegate;
@synthesize isRemindeMeInAppointment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    [viewBG release];
    [textFieldEvery release];
    [textFieldInterval release];
    [pickerView release];
    [arrayEvery release];
    [arrayTimeInterval release];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark action

- (void)setUpView {
    pickerView.frame = CGRectMake(0, 367, 320, 216);
    pickerView.hidden = YES;
    if (isRemindeMeInAppointment) {
        arrayEvery = [[NSArray alloc] initWithObjects:@"month(s)",@"day(s)",@"hour(s)",@"minute(s)", nil];
    }
    else {
        arrayEvery = [[NSArray alloc] initWithObjects:@"month(s)",@"week(s)",@"day(s)",@"hour(s)", nil];
    }
    arrayTimeInterval = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12", nil];
}

- (IBAction)hiddenKeyboard:(id)sender {
    [textFieldInterval resignFirstResponder];
    [textFieldEvery resignFirstResponder];
    [UIView animateWithDuration:0.3
                          delay: 0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         pickerView.frame = CGRectMake(0, 367, 320, 216);
                         //viewBG.frame = CGRectMake(0, 0, 320, 416);
                     }
                     completion:nil];
    pickerView.hidden = YES;
}
- (IBAction)ok:(id)sender {
    
    if (self.delegate != nil && [delegate respondsToSelector:@selector(selectRemindeMe:)]) {
        NSString *str;
        if (isRemindeMeInAppointment) {
            str = [NSString stringWithFormat:@"%@ %@ before",textFieldInterval.text, textFieldEvery.text];
        }
        else {
            str = [NSString stringWithFormat:@"every %@ %@",textFieldInterval.text, textFieldEvery.text];
        }
        [delegate selectRemindeMe:str];
    }
    
    [self setFrame:CGRectMake(480, 0, 320, 460)];
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.6];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[[self  layer] addAnimation:animation forKey:kCATransition];
    [self release];
}
- (IBAction)cancel:(id)sender {
    [self setFrame:CGRectMake(480, 0, 320, 460)];
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.6];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	
	[[self  layer] addAnimation:animation forKey:kCATransition];
    [self release];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == textFieldInterval) {
        [textField resignFirstResponder];
        selectInterval = YES;
        [pickerView reloadAllComponents];
        [pickerView selectedRowInComponent:0];
        pickerView.hidden = NO;
        [pickerView reloadAllComponents];
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             pickerView.frame = CGRectMake(0, 244, 320, 216);
                             //viewBG.frame = CGRectMake(0, -100, 320, 416);
                         }
                         completion:nil];
    }
    if (textField == textFieldEvery) {
        [textField resignFirstResponder];
        selectInterval = NO;
        [pickerView reloadAllComponents];
        [pickerView selectedRowInComponent:0];
        pickerView.hidden = NO;
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             pickerView.frame = CGRectMake(0, 244, 320, 216);
                             //viewBG.frame = CGRectMake(0, -100, 320, 416);
                         }
                         completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hiddenKeyboard:nil];
    return YES;
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pView numberOfRowsInComponent:(NSInteger)component {
	if (selectInterval) {
        return [arrayTimeInterval count];
    }
    else {
        return [arrayEvery count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (selectInterval) {
        return [arrayTimeInterval objectAtIndex:row];
    }
    else {
        return [arrayEvery objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (selectInterval) {
        textFieldInterval.text = [arrayTimeInterval objectAtIndex:row];
    }
    else {
        textFieldEvery.text = [arrayEvery objectAtIndex:row];
    }
    [UIView animateWithDuration:0.3
                          delay: 0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         pickerView.frame = CGRectMake(0, 367, 320, 216);
                         //viewBG.frame = CGRectMake(0, 0, 320, 416);
                     }
                     completion:nil];
    pickerView.hidden = YES;
}

@end
