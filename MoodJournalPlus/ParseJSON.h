

#import <Foundation/Foundation.h>

@interface ParseJSON : NSObject {
    
}
- (NSArray*)parseDataFromTextFile:(NSString*)txtFile;
- (NSMutableArray*)parseDataFromTable:(NSString*)tableName withStatus:(NSString*)status;
- (NSMutableArray*)parseDataFromTable:(NSString*)tableName withoutStatus:(NSString*)status;
@end
