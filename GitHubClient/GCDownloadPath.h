//
//  GCDownloadPath.h
//  GitHubClient
//
//  Created by mdevcon on 14/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDownloadedFile.h"

@interface GCDownloadPath : NSObject {
    NSString * _downloadPath;
    GCDownloadedFile * _data;
}

@property (copy) NSString * downloadPath;
@property (retain, nonatomic) GCDownloadedFile * data;
@property BOOL isRepo;

- (id) init: (BOOL) isRepo;
- (id) initWithDownloadPath: (NSString*) path;
- (void) saveData;
- (void) deleteData;

@end
