//
//  GCOfflineBrowserController.m
//  GitHubClient
//
//  Created by mdevcon on 14/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCOfflineBrowserController.h"
#import "GCRepositoryDatabase.h"
#import "GCDownloadPath.h"
#import "GCUtils.h"
#import "GCFileViewController.h"

@interface GCOfflineBrowserController () {
    NSArray * _items;
    NSMutableArray * _parents;
    NSString * _fileName;
    NSString * _fileContents;
}

@end

@implementation GCOfflineBrowserController

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
    _parents = [[NSMutableArray alloc] init];
    _items = [GCRepositoryDatabase getAllRepositories];
    [self.tableView reloadData];
    
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
    if (_parents.count == 0){
        return _items.count;
    } else {
        return _items.count + 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.item;
    if (_parents.count > 0){
        index--;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedRepoCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"savedRepoCell"];
    }
    if(_parents.count == 0){
        GCDownloadedFile * downloadedFile = ((GCDownloadPath *)[_items objectAtIndex:index]).data;
        cell.textLabel.text = downloadedFile.name;
        cell.imageView.image = [UIImage imageNamed:@"repository"];
    } else {
        if (index >= 0){
            GCDownloadedFile * downloadedFile = ((GCDownloadPath *)[_items objectAtIndex:index]).data;
            cell.textLabel.text = downloadedFile.name;
            if ([downloadedFile.type isEqualToString:@"dir"]){
                cell.imageView.image = [UIImage imageNamed:@"folder"];
            } else if ([downloadedFile.type isEqualToString:@"file"]){
                cell.imageView.image = [UIImage imageNamed:@"file"];
            }
        } else {
            cell.textLabel.text = @"Navigate up...";
            cell.imageView.image = [UIImage imageNamed:@"up"];
        }
    }
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.item;
    if (_parents.count > 0){
        index--;
    }
    GCDownloadedFile * downloadedFile;
    if (index == -1 ){
        if (_parents.count > 1){
            downloadedFile = [_parents objectAtIndex: _parents.count - 2];
            [_parents removeLastObject];
            
        } else {
            _items = [GCRepositoryDatabase getAllRepositories];
            [_parents removeLastObject];
            [self.tableView reloadData];

            return;
        }
    } else {
        downloadedFile = ((GCDownloadPath *)[_items objectAtIndex:index]).data;
        if ([downloadedFile.type isEqualToString:@"dir"]){
            [_parents addObject:downloadedFile];
        }
    }
    if ([downloadedFile.type isEqualToString:@"dir"]){
        NSMutableArray* newItems = [[NSMutableArray alloc] init];
        for(NSString* file in downloadedFile.containsFiles){
            GCDownloadPath *containedFile = [GCRepositoryDatabase getFileByUrl:file];
            [newItems addObject:containedFile];
        }
        _items = newItems;
        [self.tableView reloadData];
    } else {
        [self showFile: downloadedFile];
    }
}

- (void) showFile: (GCDownloadedFile *) downloadedFile {
    
    NSString * content = downloadedFile.content;
    _fileName = downloadedFile.name;
    
    // remove the newline characters
    content = [[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    BOOL isImage = [GCUtils isFileAnImage: _fileName];
    
    if (!isImage){
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSISOLatin2StringEncoding];
        if (decodedString){
            _fileContents = decodedString;
            
        }
    } else {
        _fileContents = content;
    }
    [self performSegueWithIdentifier:@"displayOfflineFileSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"displayOfflineFileSegue"]){
        GCFileViewController * fileController = [segue destinationViewController];
        fileController.fileName = _fileName;
        fileController.content = _fileContents;
    }
}

@end
