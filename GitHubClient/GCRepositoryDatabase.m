//
//  GCRepositoryDatabase.m
//  GitHubClient
//
//  Created by mdevcon on 14/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCRepositoryDatabase.h"
#import "GCDownloadedFile.h"

@implementation GCRepositoryDatabase

+ (NSString *) getDownloadedReposDir {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* reposDirectory = [paths objectAtIndex:0];
    reposDirectory = [reposDirectory stringByAppendingPathComponent:@"Downloaded Repositories"];
    NSError* error;
    [[NSFileManager defaultManager] createDirectoryAtPath:reposDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    return reposDirectory;
}

+ (NSString *) getFileDownloadPath: (NSString *) url{
    NSString * reposDirectory = [GCRepositoryDatabase getDownloadedReposDir];
    NSString * modifiedUrl = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    modifiedUrl = [modifiedUrl stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    modifiedUrl = [modifiedUrl stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSData *tempData = [modifiedUrl dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    modifiedUrl = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
    NSString * availableName = [NSString stringWithFormat:@"%@.repofile", modifiedUrl];
    return [reposDirectory stringByAppendingPathComponent:availableName];
}

+(NSString *) nextRepoDownloadPath{
    NSString * reposDirectory = [GCRepositoryDatabase getDownloadedReposDir];
    // Get contents of directory
    NSError * error;
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: reposDirectory error:&error];
    if (files == nil){
        NSLog(@"Error reading contents of repos directory: %@", [error localizedDescription]);
        return nil;
    }
    
    int maxNumber = 0;
    for (NSString * file in files){
        if([file.pathExtension compare:@"repo" options:NSCaseInsensitiveSearch] == NSOrderedSame){
            NSString * fileName = [file stringByDeletingPathExtension];
            maxNumber = MAX(maxNumber, fileName.intValue);
        }
    }
    
    NSString * availableName = [NSString stringWithFormat:@"%d.repo", maxNumber + 1];
    return [reposDirectory stringByAppendingPathComponent:availableName];
}


+ (GCDownloadPath *) getFileByUrl: (NSString *) url {
    NSString * reposDirectory = [GCRepositoryDatabase getDownloadedReposDir];
    NSLog(@"Looking for file: %@", url);
    
    //Get contents of repos directory
    NSString * modifiedUrl = [url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    modifiedUrl = [modifiedUrl stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    modifiedUrl = [modifiedUrl stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSData *tempData = [modifiedUrl dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    modifiedUrl = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
    modifiedUrl = [modifiedUrl stringByAppendingPathExtension:@"repofile"];
    NSLog(@"Modified URL: %@", modifiedUrl);
    NSString * fullPath = [reposDirectory stringByAppendingPathComponent: modifiedUrl];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: fullPath];
    if (fileExists){
        GCDownloadPath * result = [[GCDownloadPath alloc] initWithDownloadPath: fullPath];
        return result;
    } else {
        NSLog(@"File not found!");
        return nil;
    }
}

+ (NSMutableArray *) getAllRepositories {
    NSString * reposDirectory = [GCRepositoryDatabase getDownloadedReposDir];
    NSLog(@"Loading repos from; %@", reposDirectory);
    
    //Get contents of repos directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:reposDirectory error:&error];
    if (files == nil){
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    NSMutableArray * result = [[NSMutableArray alloc] init];
    for (NSString * file in files){
        if ([file.pathExtension compare:@"repo" options:NSCaseInsensitiveSearch] == NSOrderedSame){
            NSString * fullPath = [reposDirectory stringByAppendingPathComponent:file];
            GCDownloadPath * repo = [[GCDownloadPath alloc] initWithDownloadPath: fullPath];
            [result addObject:repo];
        }
    }
    return result;
}

@end
