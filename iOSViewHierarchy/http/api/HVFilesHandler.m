//
//  HVFilesHandler.m
//  iOSHierarchyViewer
//
//  Created by Maciej Gad on 06.02.2014.
//
//

#import "HVFilesHandler.h"

@implementation HVFilesHandler

+ (HVFilesHandler *)handler
{
    return [[[HVFilesHandler alloc] init] autorelease];
}

- (BOOL)handleRequest:(NSString *)url withHeaders:(NSDictionary *)headers query:(NSDictionary *)query address:(NSString *)address onSocket:(int)socket
{
    if ([super handleRequest:url withHeaders:headers query:query address:address onSocket:socket]) {
        NSMutableDictionary *responseDic = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
        [responseDic setObject:[self getFileListForPath:nil] forKey:@"files"];
        
        return [self writeJSONResponse:responseDic toSocket:socket];
    }
    return NO;
}

-(NSDictionary *) getFileListForPath:(NSString *) path{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folderPath = homePath;
    if (path) {
        folderPath = [homePath stringByAppendingPathComponent:path];
    }
    NSLog(@"filePath:%@", folderPath);
    NSError *error = [[[NSError alloc] init] autorelease];
    NSArray *array = [[[fileMgr contentsOfDirectoryAtPath:folderPath error:&error] mutableCopy] autorelease];
    if (array == nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    NSMutableDictionary *files = [[[NSMutableDictionary alloc] initWithCapacity:[array count]] autorelease];
    for (NSString *filename in array) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
        NSDictionary *fileAttr = [fileMgr attributesOfItemAtPath:filePath error:&error];
        [files setObject:[self getFileAttr:fileAttr] forKey:filename];
    }
    return files;
}

-(NSDictionary *) getFileAttr:(NSDictionary *) fileAttr{
    return @{
             @"creationDate": [fileAttr[NSFileCreationDate] description],
             @"modificationDate" :[fileAttr[NSFileModificationDate] description],
             @"fileSize":fileAttr[NSFileSize]
             };
}

@end
