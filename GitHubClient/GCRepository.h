//
//  GCRepository.h
//  GitHubClient
//
//  Created by mdevcon on 01/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCRepository : NSObject
@property(strong, nonatomic) NSString * name;
@property(strong, nonatomic) NSString * owner;
@property(strong, nonatomic) NSString * url;
@end
