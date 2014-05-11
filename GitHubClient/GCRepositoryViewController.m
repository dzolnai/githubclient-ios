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

@interface GCRepositoryViewController ()

@end

@implementation GCRepositoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
