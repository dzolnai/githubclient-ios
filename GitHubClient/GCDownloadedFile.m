//
//  GCDownloadedFile.m
//  GitHubClient
//
//  Created by mdevcon on 13/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCDownloadedFile.h"

@implementation GCDownloadedFile



#pragma mark NSCoding

#define kUrlKey       @"Url"
#define kNameKey      @"Name"
#define kContentKey   @"Content"
#define kTypeKey      @"Type"
#define kContainsKey  @"Contains"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.url forKey:kUrlKey];
    [encoder encodeObject: self.name forKey:kNameKey];
    [encoder encodeObject: self.content forKey:kContentKey];
    [encoder encodeObject: self.type forKey:kTypeKey];
    [encoder encodeObject: self.containsFiles forKey:kContainsKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.url = [decoder decodeObjectForKey:kUrlKey];
    self.name = [decoder decodeObjectForKey:kNameKey];
    self.content = [decoder decodeObjectForKey:kContentKey];
    self.type = [decoder decodeObjectForKey:kTypeKey];
    self.containsFiles = [decoder decodeObjectForKey:kContainsKey];
    return self;
}



@end
