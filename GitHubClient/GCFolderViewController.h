//
//  GCFolderViewController.h
//  GitHubClient
//
//  Created by mdevcon on 10/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCFolderViewController : UITableViewController

@property (strong, nonatomic) NSString * baseUrl;
@property (strong, nonatomic) NSString * repoName;

@end
