//
//  GCRepositoryDatabase.h
//  GitHubClient
//
//  Created by mdevcon on 14/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDownloadPath.h"

@interface GCRepositoryDatabase : NSObject

+ (NSString *) getFileDownloadPath: (NSString *) url;
+ (NSString *) nextRepoDownloadPath;
+ (GCDownloadPath *) getFileByUrl: (NSString *) url;
+ (NSMutableArray *) getAllRepositories;

@end
