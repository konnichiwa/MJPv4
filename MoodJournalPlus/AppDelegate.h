

#import <UIKit/UIKit.h>
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>  
#import <CommonCrypto/CommonCryptor.h>
typedef enum { 
    kMedication,
    kPrescriptionFill,
    kAppointment,
    kVital,
} ReminderType;

#define bgColor redColor
//#define BASE_URL @"http://107.21.219.185/CoreServices"
#define BASE_URL @"https://3zeellc.com/CoreServices"
#define application_key @"999"
#define appname @"MOODJOURNAL"
#define POPUP_TITLE @"Mood Journal"
#define APPPUSH @"MJP"
//#define deviceID @"131313132222222"
#define deviceType @"IPHONE"
#define application_salt @"1234567890123456"
#define NOT_AVAIL_OFFLINE_MSG @"Not available in Airplane Mode"

//@class YourReminderViewController;
@class Reachability;
@class BackgroundService;
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    Reachability* internetReach;
    Reachability* hostReach;
    BackgroundService *backgroundService;
    BOOL havePushNotification;
    BOOL haveLocalNotification;
    NSTimer *timer;
    NSMutableArray *arrayMsgidNofify;
    
    BOOL hadLocalNotificationInBackground;
    
    BOOL allowShowAlert;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *naviController;
@property (nonatomic, retain) NSMutableDictionary *dictSetting;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *reminderTime;
@property (nonatomic, retain) NSString *frequency;
@property (nonatomic, retain) NSString *medicationImageLink;
@property (nonatomic, retain) NSString *deviceID;
@property (nonatomic, retain) NSString *pushNotificationToken;

@property (nonatomic, assign) BOOL theFirstShowYourReminder;
@property (nonatomic, assign) BOOL isLoadingYourReminder;//registerNotification
@property (nonatomic, assign) BOOL registerNotification;
@property (nonatomic, assign) BOOL theFirstShowSetupReminder;
@property (nonatomic, assign) BOOL theFirstShowHistory;
@property (nonatomic, assign) BOOL theFirstLoadMedication;

@property (nonatomic, retain) NSMutableArray *arrayYourReminders;
@property (nonatomic, retain) NSMutableArray *arrayUpcomingReminder;

@property (nonatomic, assign) BOOL isHaveInternetConnection;
//varible of addsubcategory, store list category, dictionary, key

@property (nonatomic, retain) NSMutableArray *appMedicationList;
@property (nonatomic, retain) NSMutableDictionary *appDict;
@property (nonatomic, retain) NSMutableArray *appKey;
//end varible of addsubcategory
@property BOOL showDetailFirst;
//@property (nonatomic, retain) NSString *pushNotificationToken;

@property (nonatomic, retain) BackgroundService *backgroundService;
@property (nonatomic, retain) NSMutableArray *arrayLocalNotification;
@property (nonatomic, retain) NSMutableArray *arrayMsgidNofify;

@property (nonatomic, retain) NSMutableArray *arraySetupReminders;

@property (nonatomic, retain) NSMutableArray *arrayKeys;
@property (nonatomic, retain) NSMutableDictionary *dictionaryMedicationList;

@property (nonatomic, retain) NSMutableDictionary *dictYourReminder;
@property (nonatomic, retain) NSMutableArray *keysYourReminder;

@property (nonatomic, assign) BOOL isFirstSignUp;
@property (nonatomic, assign) BOOL isSecondSignUp;
@property (nonatomic, assign) BOOL isHavePushNotificationOnBackground;

@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) BOOL needToSync;
@property (nonatomic, retain) NSDictionary *dictBanner;
@property (nonatomic, assign) BOOL isDownloadMotivationalMessage;
@property (nonatomic, assign) BOOL isAirplaneModeSet;
@property (nonatomic, assign) BOOL isFirstConnectionTested;

@property (nonatomic, retain) NSMutableArray *arrayTodayHistory;
@property (nonatomic, assign) BOOL syned;

 
- (NSString *)pushNotification;
- (NSString*) doCipher:(NSString*)plainText:(CCOperation)encryptOrDecrypt;
- (NSString *)getProperty: (NSString *)key forData: (NSDictionary *)dataList;
- (void) showLoginViewWhenAuthenFailed;
- (BOOL) hasErrorMessage: (NSDictionary*)respondData;
- (void)sortMedicationList;
- (NSMutableArray*)sortReminderByDeleveryDate;
- (void)showLoginViewWhenWrongPass;
- (NSString*)convertDateFromFloatString:(NSString*)floatString toDateStype:(BOOL)date withTimeZone:(NSString*)timeZone;
-(void)delReminderExpire;
@end
