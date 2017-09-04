//
//  HomeViewController.m
//  EPubReader
//
//  Created by apple QJX on 12-6-15.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import "HomeViewController.h"
#import "EpubReaderViewController.h"
@implementation HomeViewController
@synthesize array;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"EPUB 阅读器";
    _tableView.separatorColor = [UIColor clearColor];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    NSString *listPath = [[NSBundle mainBundle] pathForResource:@"EpubFiles" ofType:@"plist"];
    self.array = [NSArray arrayWithContentsOfFile:listPath];
}

#pragma mark -tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    bookCell = (BookCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (bookCell == nil){
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"BookCell" owner:self options:nil];
        for (id currentObj in topLevelObject){
            if ([currentObj isKindOfClass:[UITableViewCell class]]){
                bookCell = (BookCell *)currentObj;
                break;
            }
        }
    }
    NSDictionary *tmpDict = [self.array objectAtIndex:indexPath.section];
    bookCell.mainLabel.text = [tmpDict valueForKey:@"Displayname"];
    bookCell.subLabel.text = [tmpDict valueForKey:@"Authorname"];
    bookCell.imageView.image = [UIImage imageNamed:[tmpDict valueForKey:@"Image"]];
    [bookCell setBackgroundColor:[UIColor clearColor]];
    return bookCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EpubReaderViewController *_epubReaderViewController = [[EpubReaderViewController alloc] initWithNibName:@"EpubReaderViewController" bundle:nil];
    NSDictionary *tmpDict = [self.array objectAtIndex:indexPath.section];
    _epubReaderViewController._strFileName = [tmpDict valueForKey:@"Filename"];
    [_epubReaderViewController settitleName:[tmpDict valueForKey:@"Displayname"]];
    [self.navigationController pushViewController:_epubReaderViewController animated:YES];
    [_epubReaderViewController release];
    _epubReaderViewController = nil;
}

- (void)dealloc{
    [array release];
    array = nil;
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
