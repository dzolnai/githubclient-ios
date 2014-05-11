//
//  GCFile.h
//  GitHubClient
//
//  Created by mdevcon on 11/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCFile : NSObject

@property(strong, nonatomic) NSString * name;
@property(strong, nonatomic) NSString * url;
@property(strong, nonatomic) NSString * type;

@end
