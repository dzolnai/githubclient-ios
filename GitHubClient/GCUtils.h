//
//  GCUtils.h
//  GitHubClient
//
//  Created by mdevcon on 13/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCUtils : NSObject

+ (BOOL) isFileAnImage: (NSString *) fileName;
+ (void) downloadFilesRecursivelyFrom: (NSString *) url withName: (NSString *) name isRepoRoot: (BOOL) isRepo whenFinished: (void (^)(void)) block ;
+ (NSUInteger) getActiveCalls;
@end
