//
//  GCAppDelegate.h
//  GitHubClient
//
//  Created by mdevcon on 01/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface GCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AFHTTPRequestOperationManager * networkingManager;

@end
