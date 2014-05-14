//
//  GCDownloadPath.m
//  GitHubClient
//
//  Created by mdevcon on 14/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCDownloadPath.h"
#import "GCRepositoryDatabase.h"

#define kDataKey    @"Data"
#define kDataFile   @"data.plist"

@implementation GCDownloadPath

@synthesize downloadPath = _downloadPath;
@synthesize data = _data;
@synthesize isRepo = _isRepo;

- (id) init: (BOOL) isRepo {
    if ((self = [super init])){
        _isRepo = isRepo;
    }
    return self;
}

- (id) initWithDownloadPath: (NSString*) path {
    if ((self = [super init])){
        _downloadPath = path;
    }
    return self;
}

- (BOOL) createDownloadPath {
    if (_downloadPath == nil){
        if (_isRepo){
            self.downloadPath = [GCRepositoryDatabase nextRepoDownloadPath];
        } else {
            self.downloadPath = [GCRepositoryDatabase getFileDownloadPath: _data.url];
        }
    }
    NSError * error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_downloadPath withIntermediateDirectories: YES attributes: nil error:&error];
    if (!success){
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
}

- (GCDownloadedFile *) data {
    if (_data != nil) {
        return _data;
    }
    NSString * dataPath = [_downloadPath stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil)
        return nil;
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _data = [unarchiver decodeObjectForKey:kDataKey];
    [unarchiver finishDecoding];
    return _data;
}

- (void) saveData {
    if (_data == nil) {
        NSLog(@"No data on the path!");
        return;
    }
    [self createDownloadPath];
    NSString * dataPath = [_downloadPath stringByAppendingPathComponent:kDataFile];
    NSMutableData * data = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
}

- (void) deleteData {
    NSError * error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_downloadPath error:&error];
    if (!success){
        NSLog(@"Error removing repository: %@", [error localizedDescription]);
    }
}

@end
