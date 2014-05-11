//
//  GCFileViewController.m
//  GitHubClient
//
//  Created by mdevcon on 11/05/14.
//  Copyright (c) 2014 BME. All rights reserved.
//

#import "GCFileViewController.h"

@interface GCFileViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation GCFileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.fileName){
        self.title = self.fileName;
    } else {
        self.title = @"File";
    }
    // convert the spaces to non breaking ones
    self.content = [self.content stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
    // convert the newlines to br tags
    self.content = [self.content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    // change the font with the html
    self.content = [NSString stringWithFormat:@"<html> \n"
                    "<head> \n"
                    "<style type=\"text/css\"> \n"
                    "body {font-family: \"%@\"; font-size: %@;}\n"
                    "</style> \n"
                    "</head> \n"
                    "<body>%@</body> \n"
                    "</html>", @"TrebuchetMS", [NSNumber numberWithInt:12], self.content];
    if (self.content){
        [self.webView loadHTMLString:self.content baseURL:nil];
    }
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
