//
//  GCFolderViewController.m
//  GitHubClient
//
//  Created by mdevcon on 10/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCFolderViewController.h"
#import "GCAppDelegate.h"
#import "GCFile.h"
#import "GCFileViewController.h"

@interface GCFolderViewController () {
    
    NSArray * _currentItems;
    NSMutableArray * _parents;
    
    NSString * _fileName;
    NSString * _fileContents;
}

@end

@implementation GCFolderViewController

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
    // if reponame is not set, just set Repository, as the title
    if (self.repoName){
        self.title = self.repoName;
    } else {
        self.title = @"Repository";
    }
    
    self.baseUrl = [self.baseUrl stringByAppendingString: @"/contents/"];
    _parents = [[NSMutableArray alloc] init];
    [_parents addObject:self.baseUrl];
    
    GCAppDelegate *appDelegate = (GCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.networkingManager GET:self.baseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self parseReceivedFiles:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error!");
    }];
}

- (void) parseReceivedFiles: (id) json {
    // Use this for logging the output of the call
    //NSLog(@"JSON: %@", json);
    NSArray *jsonDict = (NSArray *) json;
    NSMutableArray * files = [[NSMutableArray alloc] init];
    [jsonDict enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop){
        GCFile * file = [[GCFile alloc] init];
        file.name = [obj objectForKey:@"name"];
        file.url = [obj objectForKey:@"url"];
        file.type = [obj objectForKey:@"type"];
        [files addObject: file];
    }];
    
    _currentItems = files;
    [self.tableView reloadData];
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
    if (_parents.count == 1){
        return _currentItems.count;
    } else {
        return _currentItems.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repositoryCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"repositoryCell"];
    }
    if (_parents.count > 1 && indexPath.item == 0){
        cell.textLabel.text = @"Navigate up...";
        cell.imageView.image = [UIImage imageNamed:@"up"];
    } else {
        int index = indexPath.item;
        if (_parents.count > 1) {
            index--;
        }
        GCFile* file = (GCFile*) [_currentItems objectAtIndex: index];
        cell.textLabel.text = file.name;
        if ([file.type isEqualToString:@"dir"]){
            cell.imageView.image = [UIImage imageNamed:@"folder"];
        } else if ([file.type isEqualToString:@"file"]){
            cell.imageView.image = [UIImage imageNamed:@"file"];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.item;
    bool isFile = NO;
    if (_parents.count > 1) {
        index--;
    }
    NSString * urlToFetch;
    if (index == -1){
        urlToFetch = [_parents objectAtIndex:_parents.count - 2];
    } else {
        GCFile* file = (GCFile*) [_currentItems objectAtIndex: index];
        urlToFetch = file.url;
        if ([file.type isEqualToString:@"file"]){
            isFile = YES;
        }
    }
    // we must URL encode the urls from the API, because they can easily contain characters
    // which can't belong there, like hungarian characters.
    urlToFetch =[urlToFetch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // Uncomment this to watch the parents stack depth and the url to fetch:
    //NSLog(@"%d url: %@", _parents.count, urlToFetch);
    
    GCAppDelegate *appDelegate = (GCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.networkingManager GET:urlToFetch parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(!isFile){
            if (index == -1){
                [_parents removeLastObject];
            } else {
                [_parents addObject:urlToFetch];
            }
            [self parseReceivedFiles:responseObject];
        } else {
            [self parseFile:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error!");
    }];
}

- (void) parseFile: (id) json {
    // Use this for logging the output of the call
    // NSLog(@"JSON: %@", json);
    
    NSDictionary *jsonDict = (NSDictionary *) json;
    
    NSString * content = [jsonDict objectForKey:@"content"];
    NSString * encoding = [jsonDict objectForKey:@"encoding"];
    
    content = [[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    
    if([encoding isEqualToString:@"base64"]){
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSISOLatin2StringEncoding];
        if (decodedString){
            _fileContents = decodedString;
            _fileName = [jsonDict objectForKey:@"name"];
            [self performSegueWithIdentifier:@"displayFileSegue" sender:self];
        }
    }
    // TODO display alert
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"displayFileSegue"]){
        GCFileViewController * fileController = [segue destinationViewController];
        fileController.fileName = _fileName;
        fileController.content = _fileContents;
    }
}



@end
