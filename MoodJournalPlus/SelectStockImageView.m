

#import "SelectStockImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SelectStockImageView
@synthesize delegate;

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
    [textFieldItem release];
    [textFieldColor release];
    [textFieldShowColor release];
    [pickerView release];
    [strItem release];
    [imageViewItem release];
    [arrayItem release];
    [arrayColor release];
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
    arrayItem = [[NSArray alloc] initWithObjects:@"white_bottle",@"white_capsule",@"white_oval",@"white_rectangle",@"white_round", nil];
    arrayColor = [[NSArray alloc] initWithObjects:@"blue",@"grey",@"orange",@"pink",@"purple",@"red",@"white", nil];
    imageViewItem.image = [UIImage imageNamed:[arrayItem objectAtIndex:0]];
}
- (IBAction)ok:(id)sender {
    NSLog(@"%@",strColor);
    if (strColor == nil) {
        strColor = @"blue";
    }
    if (strItem == nil) {
        strItem = @"bottle";
    }
    if (self.delegate != nil && [delegate respondsToSelector:@selector(selectStockImage:)]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@",strColor,strItem] ofType:@"png"];
        //NSString *str = [NSString stringWithFormat:@"%@_%@.png",strColor,strItem];
        [delegate selectStockImage:bundle];
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
- (IBAction)hiddenKeyboard:(id)sender {
    [textFieldItem resignFirstResponder];
    [textFieldColor resignFirstResponder];
    [textFieldShowColor resignFirstResponder];
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

#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == textFieldItem) {
        [textField resignFirstResponder];
        selectItem = YES;
        [pickerView reloadAllComponents];
        [pickerView selectedRowInComponent:0];
        pickerView.hidden = NO;
        [pickerView reloadAllComponents];
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             pickerView.frame = CGRectMake(0, 244, 320, 216);
                         }
                         completion:nil];
    }
    if (textField == textFieldColor) {
        [textField resignFirstResponder];
        selectItem = NO;
        [pickerView reloadAllComponents];
        [pickerView selectedRowInComponent:0];
        pickerView.hidden = NO;
        [UIView animateWithDuration:0.3
                              delay: 0.0
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             pickerView.frame = CGRectMake(0, 244, 320, 216);
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
	if (selectItem) {
        return [arrayItem count];
    }
    else {
        return [arrayColor count];
    }
}

//- (NSString *)pickerView:(UIPickerView *)pView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//	if (selectItem) {
//        return [arrayItem objectAtIndex:row];
//    }
//    else {
//        return [arrayColor objectAtIndex:row];
//    }
//}
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (selectItem) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[arrayItem objectAtIndex:row]]]];
        return [imageView autorelease];

    }
    else {
        UILabel *label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(0, 0, 200, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:17];
        label.text = [NSString stringWithFormat:@"  %@",[arrayColor objectAtIndex:row]];
        return [label autorelease];
    }
}
- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (selectItem) {
        //textFieldItem.text = [NSString stringWithString:[[[arrayItem objectAtIndex:row] componentsSeparatedByString:@"_"]objectAtIndex:1]];
        if (strItem != nil) {
            [strItem release];
            strItem = nil;
        }
        strItem = [[NSString alloc] initWithString:[[[arrayItem objectAtIndex:row] componentsSeparatedByString:@"_"]objectAtIndex:1]];
        imageViewItem.image = [UIImage imageNamed:[arrayItem objectAtIndex:row]];
    }
    else {
        if (strColor != nil) {
            [strColor release];
            strColor = nil;
        }
        strColor = [[NSString alloc] initWithString:[arrayColor objectAtIndex:row]];
        if ([strColor isEqualToString:@"blue"]) {
            textFieldShowColor.backgroundColor = [UIColor blueColor];
        }
        if ([strColor isEqualToString:@"grey"]) {
            textFieldShowColor.backgroundColor = [UIColor grayColor];
        }
        if ([strColor isEqualToString:@"orange"]) {
            textFieldShowColor.backgroundColor = [UIColor orangeColor];
        }
        if ([strColor isEqualToString:@"pink"]) {
            textFieldShowColor.backgroundColor = [UIColor colorWithRed:1 green: 0.6 blue:0.8 alpha:1];
        }
        if ([strColor isEqualToString:@"purple"]) {
            textFieldShowColor.backgroundColor = [UIColor purpleColor];
        }
        if ([strColor isEqualToString:@"red"]) {
            textFieldShowColor.backgroundColor = [UIColor redColor];
        }
        if ([strColor isEqualToString:@"white"]) {
            textFieldShowColor.backgroundColor = [UIColor whiteColor];
        }
        //textFieldShowColor.text = [arrayColor objectAtIndex:row];
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
