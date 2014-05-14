//
//  GCDownloadedFile.h
//  GitHubClient
//
//  Created by mdevcon on 13/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDownloadedFile : NSObject <NSCoding>

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * url;
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSArray * containsFiles;

@end
