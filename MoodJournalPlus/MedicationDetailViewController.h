//
//  MedicationDetailViewController.h
//  MoodJournalPlus
//
//  Created by Java-Dive on 1/13/12.
//  Copyright (c) Java-Dive Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadImage;
@interface MedicationDetailViewController : UIViewController {
    IBOutlet UILabel *labelName;
    IBOutlet UILabel *labelImprint;
    IBOutlet UILabel *labelColor;
    IBOutlet UILabel *labelSize;
    IBOutlet UILabel *labelIngredient;
    IBOutlet UILabel *labelInactiveIngredient;
    IBOutlet UILabel *labelAuthorText;
    IBOutlet UILabel *labelAuthor;
    IBOutlet UILabel *labelShape;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *imageViewBG;
    
    DownloadImage *downloadImage;
    NSString *stringLinkImage;
}
@property (nonatomic, retain) NSDictionary *dictMedicationDetail;

- (IBAction)pressBack:(id)sender;
@end
