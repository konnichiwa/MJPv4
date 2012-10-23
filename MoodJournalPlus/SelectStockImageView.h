

#import <UIKit/UIKit.h>

@protocol SelectStockImageViewDelegate <NSObject>
@required 
-(void)selectStockImage:(NSString*)image;
@end

@interface SelectStockImageView : UIView <UITextFieldDelegate, UIPickerViewDelegate>{
    IBOutlet UITextField *textFieldItem;
    IBOutlet UIImageView *imageViewItem;
    IBOutlet UITextField *textFieldColor;
    IBOutlet UITextField *textFieldShowColor;
    IBOutlet UIPickerView *pickerView;
    
    NSArray *arrayItem;
    NSArray *arrayColor;
    BOOL selectItem;
    NSString *strColor;
    NSString *strItem;
}
@property (nonatomic, assign) id <SelectStockImageViewDelegate> delegate;

- (void)setUpView;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)hiddenKeyboard:(id)sender;
@end
