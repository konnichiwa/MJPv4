
#import "DownloadImage.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"

@implementation DownloadImage 
@synthesize viewController;
@synthesize networkQueue;

- (void)dealloc {
    [super dealloc];
    //networkQueue.delegate = nil;
    //[networkQueue release];
    //[viewController release];
}

- (void)downloadImageWithData:(NSArray*)arrayImage {
    if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];	
	}
    [networkQueue reset];
	[networkQueue setRequestDidFinishSelector:@selector(imageFetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];
	[networkQueue setDelegate:viewController];
    
    for (int i = 0; i < [arrayImage count]; i++) {
        ASIHTTPRequest *request1;
        request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[arrayImage objectAtIndex:i]]];
        [request1 setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[arrayImage objectAtIndex:i] componentsSeparatedByString:@"/"] lastObject]]];
        [request1 setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
        [networkQueue addOperation:request1];
    }
    [networkQueue go];
}

@end
