

#import <Foundation/Foundation.h>

@class ASINetworkQueue;
@class ASIFormDataRequest;
@interface DownloadImage : NSObject {
    ASINetworkQueue *networkQueue;
}
- (void)downloadImageWithData:(NSArray*)arrayImage;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@end
