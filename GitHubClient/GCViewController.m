//
//  GCViewController.m
//  GitHubClient
//
//  Created by mdevcon on 01/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCViewController.h"
#import "AFNetworking.h"
#import "GCAppDelegate.h"
#import "GCRepositoryViewController.h"
#import "GCRepository.h"
#import "GCOfflineBrowserController.h"
#import "MBProgressHUD.h"

@interface GCViewController()  <UITextFieldDelegate> {
    NSMutableArray * _repositories;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;



@end

@implementation GCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

-(void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y - 190);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButtonTouchUpInside:(id)sender {
    
    [self dismissKeyboard];
    
    NSString * userName = self.usernameTextField.text;
    NSString * password = self.passwordTextField.text;
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    
    // Set indeterminate mode
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Logging in...";
    [hud show:YES];
    
    GCAppDelegate *appDelegate = (GCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.networkingManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [appDelegate.networkingManager.requestSerializer setAuthorizationHeaderFieldWithUsername: userName password: password];
    [appDelegate.networkingManager GET:@"https://api.github.com/user/repos" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [self pushRepositoryControllerWithRepos: responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        self.passwordTextField.layer.borderColor = [[UIColor redColor] CGColor];
        self.passwordTextField.layer.borderWidth = 2.0;
    }];
    
}

- (IBAction)pushRepositoryControllerWithRepos: (id) responseObject
{
    // Use this for logging the output of the call
    // NSLog(@"JSON: %@", responseObject);
    NSArray *jsonDict = (NSArray *) responseObject;
    NSMutableArray * repos = [[NSMutableArray alloc] init];
    [jsonDict enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        GCRepository * repo = [[GCRepository alloc] init];
        repo.name = [obj objectForKey:@"name"];
        repo.owner = [[obj objectForKey:@"owner"] objectForKey:@"login"];
        repo.url = [obj objectForKey:@"url"];
        [repos addObject: repo];
    }];
    
    _repositories = repos;
    
    [self performSegueWithIdentifier:@"browseRepositoriesSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"browseRepositoriesSegue"]){
        GCRepositoryViewController *repoController = [segue destinationViewController];
        repoController.repositories = _repositories;
    }
    if ([[segue identifier] isEqualToString:@"browseSavedRepositoriesSegue"]){
        //GCOfflineBrowserController *repoController = [segue destinationViewController];
        // Don't do anything here
    }
}

@end
