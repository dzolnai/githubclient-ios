//
//  GCRepositoryViewController.m
//  GitHubClient
//
//  Created by mdevcon on 01/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCRepositoryViewController.h"
#import "GCRepository.h"
#import "GCFolderViewController.h"
#import "GCUtils.h"
#import "MBProgressHUD.h"

@interface GCRepositoryViewController () {
    int _lastClickedIndex;
}

@end

@implementation GCRepositoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _lastClickedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath){
            _lastClickedIndex = indexPath.row;
            GCRepository * selectedRepo = (GCRepository*) [self.repositories objectAtIndex: indexPath.row];
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Download repository"
                                                                 message: [NSString stringWithFormat:@"Do you want to save this repository for offline use: %@?", selectedRepo.name]
                                                                delegate:self
                                                                cancelButtonTitle:@"No thanks"
                                                                otherButtonTitles:@"Yes", nil];
            [alertView show];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// tapped yes
	if (buttonIndex != [alertView cancelButtonIndex])
	{
        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        // Set indeterminate mode
        HUD.mode = MBProgressHUDModeIndeterminate;
        
        HUD.labelText = @"Downloading";
        
        [HUD show:YES];
        
        GCRepository * repo = (GCRepository*) [self.repositories objectAtIndex:_lastClickedIndex];
        [GCUtils downloadFilesRecursivelyFrom:[repo.url stringByAppendingString: @"/contents/"] withName:repo.name isRepoRoot: YES whenFinished: ^{
            [HUD hide:YES];
        }];
		
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.repositories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repositoryCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"repositoryCell"];
    }
    cell.detailTextLabel.text = ((GCRepository *)[self.repositories objectAtIndex:indexPath.item]).owner;
    cell.textLabel.text = ((GCRepository *)[self.repositories objectAtIndex:indexPath.item]).name;
    cell.imageView.image = [UIImage imageNamed:@"repository"];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    [cell addGestureRecognizer:lpgr];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"browseCodeSegue"])
    {
        GCFolderViewController *folderViewController = segue.destinationViewController;
        int index = self.tableView.indexPathForSelectedRow.item;
        folderViewController.baseUrl = ((GCRepository*)[self.repositories objectAtIndex:index]).url;
        folderViewController.repoName = ((GCRepository*)[self.repositories objectAtIndex:index]).name;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"browseCodeSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
}


@end
