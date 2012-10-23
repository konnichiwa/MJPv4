

#import "RestConnection.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <CommonCrypto/CommonCryptor.h>


@implementation RestConnection 
@synthesize request;
@synthesize viewController;
@synthesize isBackgroudService;

- (void)dealloc {
    [super dealloc];
    request.delegate = nil;
    [request release];
    [viewController release];
}

- (void)getDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param forService:(NSString*)service {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    //NSString *sk = [self sha1:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]];
    NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    //NSString *sk = @"1329187360190";
    [arr addObject:[NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",sk] forKey:@"sk"]];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    NSLog(@"%@",api_signture);
    [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    for (int i = 0; i < [arr count]; i++) {
        if (i < [arr count]-1) {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
    }
    
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    NSLog(@"Link Request %@",linkRequest);
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    
    [request setRequestMethod:@"GET"];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}

- (void)postDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSString*)postData {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:sk forKey:@"sk"]];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    for (int i = 0; i < [arr count]; i++) {
        if (i < [arr count]-1) {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
    }
    
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    [request setPostBody:(NSMutableData*)[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
        [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    NSLog(@"Link request: %@ \n posted data: %@ param %@",linkRequest,postData,param);
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}


- (void)postDataWithPathSource2:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSArray*)postData {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    NSString *sk =[NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    //NSString *sk = @"1329100015904";
    sk = [sk stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:sk forKey:@"sk"]];
    NSMutableArray *arr1 = [NSMutableArray arrayWithArray:arr];
    
    [arr addObjectsFromArray:postData];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    
    [arr1 addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    
    for (int i = 0; i < [arr1 count]; i++) {
        if (i < [arr1 count]-1) {
            NSString *key = [[[arr1 objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr1 objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr1 objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr1 objectAtIndex:i] objectForKey:key]];
        }
    }
    
    NSLog(@"%@",linkRequest);
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    //[request setPostBody:(NSMutableData*)[postData dataUsingEncoding:NSUTF8StringEncoding]];
    for (int i = 0; i < [postData count]; i++) {
        NSString *key = [[[postData objectAtIndex:i] allKeys] objectAtIndex:0];
        [request setPostValue:[[postData objectAtIndex:i] objectForKey: key] forKey:key];
    }
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"]];
    [request setRequestMethod:@"POST"];
    
    NSLog(@"Link request: %@ \n posted data: %@ param %@",linkRequest,postData,param);
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}


- (void)postDataWithPathSource3:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSArray*)postData {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    sk = [sk stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:sk forKey:@"sk"]];
    NSMutableArray *arr1 = [NSMutableArray arrayWithArray:arr];
    
    [arr addObjectsFromArray:postData];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    
    [arr1 addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    
    for (int i = 0; i < [arr1 count]; i++) {
        if (i < [arr1 count]-1) {
            NSString *key = [[[arr1 objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr1 objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr1 objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr1 objectAtIndex:i] objectForKey:key]];
        }
    }
    NSString *pData = [NSString stringWithFormat:@""];
    
    for (int i = 0; i < [postData count]; i++) {
        if (i < [postData count]-1) {
            NSString *key = [[[postData objectAtIndex:i] allKeys] objectAtIndex:0]; 
            NSString *a = [[postData objectAtIndex:i] objectForKey:key];
            NSString* escapedUrlString = (NSString *)
            CFURLCreateStringByAddingPercentEscapes(NULL,
                                                    (CFStringRef)a,
                                                    NULL,
                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                    CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding));
            pData = [pData stringByAppendingFormat:@"%@=%@&",key,escapedUrlString];
        }
        else {
            NSString *key = [[[postData objectAtIndex:i] allKeys] objectAtIndex:0];            NSString *a = [[postData objectAtIndex:i] objectForKey:key];
            NSString* escapedUrlString = (NSString *)
            CFURLCreateStringByAddingPercentEscapes(NULL,
                                                    (CFStringRef)a,
                                                    NULL,
                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                    CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding));
            pData = [pData stringByAppendingFormat:@"%@=%@&",key,escapedUrlString];
        }
    }
    
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    [request setPostBody:(NSMutableData*)[pData dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setPostBody:(NSMutableData*)[pData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"]];
    [request setRequestMethod:@"POST"];
    NSLog(@"Link request: %@ \n posted data: %@",linkRequest,pData);
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}
/*- (void)postDataWithPathSource3:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSString*)postData {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    NSString *sk = [NSString stringWithFormat:@"%10.0f000",[[NSDate date] timeIntervalSince1970]];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:sk forKey:@"sk"]];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    for (int i = 0; i < [arr count]; i++) {
        if (i < [arr count]-1) {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
    }
    
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    [request setPostBody:(NSMutableData*)[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"]];
    
    [request setRequestMethod:@"POST"];
    NSLog(@"Link request: %@ \n posted data: %@",linkRequest,postData);
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}*/


- (void)putDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param withPostData:(NSString*)postData {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:sk forKey:@"sk"]];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    for (int i = 0; i < [arr count]; i++) {
        if (i < [arr count]-1) {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
    }
    
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    [request setPostBody:(NSMutableData*)[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"]];
    [request setRequestMethod:@"PUT"];
    NSLog(@"put data %@",linkRequest);
    if (!isBackgroudService) {
        [request setDelegate:viewController];
    }
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}

- (void)deleteDataWithPathSource:(NSString *)pathSource andParam:(NSArray*)param withReminderID:(NSString*)reminderID {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:param];
    NSString *linkRequest = [NSString stringWithFormat:@"%@%@?",BASE_URL,pathSource];
    //NSString *sk = [self sha1:[NSString stringWithFormat:@"%10.0f000",[[NSDate date] timeIntervalSince1970]]];
    NSString *sk = [NSString stringWithFormat:@"%13.0f",[[NSDate date] timeIntervalSince1970]*1000];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:sk forKey:@"sk"]];
    arr = [self sortArrayByAlphabet:arr];
    NSString *api_signture = [self createSignatureWithPathSource:pathSource andParam:arr];
    [arr addObject:[NSMutableDictionary dictionaryWithObject:api_signture forKey:@"api_sig"]];
    
    for (int i = 0; i < [arr count]; i++) {
        if (i < [arr count]-1) {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@&",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
        else {
            NSString *key = [[[arr objectAtIndex:i] allKeys] objectAtIndex:0];
            linkRequest = [linkRequest stringByAppendingFormat:@"%@=%@",key,[[arr objectAtIndex:i] objectForKey:key]];
        }
    }
    
    [request cancel];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:linkRequest]]]];
    [request setRequestMethod:@"DELETE"];
    NSLog(@"delete data %@",linkRequest);
    [request setDelegate:viewController];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    [request setShouldContinueWhenAppEntersBackground:YES];
#endif
    [request startAsynchronous];
}

- (NSString *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return [s lowercaseString];
    /*str = [str stringByReplacingOccurrencesOfString:@"+" withString:@""];
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;*/
    
}

- (NSString*)createSignatureWithPathSource:(NSString*)pathSource andParam:(NSArray*)arrayParam {
    BOOL hasToken = NO;
    NSString *token;
    for (int i = 0; i < [arrayParam count]; i++) {
        if ([[arrayParam objectAtIndex:i] objectForKey:@"token"] != nil) {
            hasToken = YES;
            token = [[arrayParam objectAtIndex:i] objectForKey:@"token"];
            break;
        }
    }
    NSString *salt = @"1234567890123456";
    if (hasToken) {
        salt = [token stringByAppendingString:salt];
    }
    
    
    NSString *string = [salt stringByAppendingString:pathSource];
    for (int i = 0; i < [arrayParam count]; i++) {
        NSString *key = [[[arrayParam objectAtIndex:i] allKeys] objectAtIndex:0];
        string = [string stringByAppendingString:key];
        string = [string stringByAppendingString:[[arrayParam objectAtIndex:i] objectForKey:key]];
    }
    return [self sha1:string];
}

- (NSMutableArray*)sortArrayByAlphabet:(NSArray*)array {
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSString *char1 = [[obj1 allKeys] objectAtIndex:0];
        NSString *char2 = [[obj2 allKeys] objectAtIndex:0];
        NSComparisonResult comparison = [char1 localizedCaseInsensitiveCompare:char2];
        return comparison;
    }];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:sortedArray];
    return [arr autorelease];
}
@end
