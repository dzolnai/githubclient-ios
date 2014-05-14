//
//  GCUtils.m
//  GitHubClient
//
//  Created by mdevcon on 13/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCUtils.h"
#import "GCAppDelegate.h"
#import "GCDownloadedFile.h"
#import "GCDownloadPath.h"


@implementation GCUtils

static NSUInteger _activeCalls = 0;

+ (BOOL) isFileAnImage: (NSString *) fileName {
    NSString * extension = [fileName pathExtension];
    if ([extension isEqualToString:@"jpg"]){
        return YES;
    }
    if ([extension isEqualToString:@"png"]){
        return YES;
    }
    if ([extension isEqualToString:@"jpeg"]){
        return YES;
    }
    return NO;
}

+ (void) downloadFilesRecursivelyFrom: (NSString *) url withName: (NSString *) name isRepoRoot: (BOOL) isRepo whenFinished: (void (^)(void)) block {
    _activeCalls++;
    NSString * urlToFetch =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    GCAppDelegate *appDelegate = (GCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.networkingManager GET:urlToFetch parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self parseDownloadedFilesFromJson:responseObject fromUrl: url withName:name isRepoRoot: isRepo whenFinished:block];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error!");
    }];
}

+ (void) parseDownloadedFilesFromJson: (id) json fromUrl: (NSString *) url withName: (NSString*) name isRepoRoot: (BOOL) isRepo whenFinished: (void (^) (void)) block {
    // to debug the call uncomment the following line
    //NSLog(@"%@", json);
    GCDownloadedFile * downloadedFile = [[GCDownloadedFile alloc] init];
    downloadedFile.url = url;
    downloadedFile.name = name;
    if ([json isKindOfClass: [NSArray class]]){
        // its a directory
        downloadedFile.type = @"dir";
        NSArray *jsonArray = (NSArray *) json;
        NSMutableArray * files = [[NSMutableArray alloc] init];
        NSMutableArray * names = [[NSMutableArray alloc] init];
        [jsonArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
            NSString * url = [obj objectForKey:@"url"];
            NSString * name = [obj objectForKey:@"name"];
            [files addObject: url];
            [names addObject:name];
        }];
        downloadedFile.containsFiles = files;
        
        for(int i = 0; i < files.count; i++){
            NSString * fileUrl = [files objectAtIndex:i];
            NSString * fileName = [names objectAtIndex:i];
            [GCUtils downloadFilesRecursivelyFrom:fileUrl withName:fileName isRepoRoot: NO whenFinished:block];
        }
    } else {
        // its a file
        downloadedFile.type=@"file";
        NSDictionary* jsonDict = (NSDictionary*) json;
        downloadedFile.content=[jsonDict objectForKey:@"content"];
    }
    GCDownloadPath * downloadedPath = [[GCDownloadPath alloc] init:isRepo];
    downloadedPath.data = downloadedFile;
    [downloadedPath saveData];
    _activeCalls--;
    if (_activeCalls == 0){
        block();
    }
    NSLog(@"Created file named: %@ with type: %@. Currently active calls: %d", downloadedFile.name, downloadedFile.type, _activeCalls);
}

+ (NSUInteger) getActiveCalls {
    return _activeCalls;
}

@end
