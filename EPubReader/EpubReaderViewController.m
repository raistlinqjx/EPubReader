//
//  EpubReaderViewController.m
//  EPubReader
//
//  Created by apple QJX on 12-6-12.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import "EpubReaderViewController.h"
@implementation EpubReaderViewController
@synthesize _ePubContent, _rootPath, _strFileName;

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

- (void)dealloc{
    [_webView release];
    _webView = nil;
    [_ePubContent release];
    _ePubContent = nil;
    _pagesPath = nil;
    _rootPath = nil;
    [_strFileName release];
    _strFileName = nil;
    [_backGroundImage release];
    _backGroundImage = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackButton];
    [_webView setBackgroundColor:[UIColor clearColor]];
    [self unzipAndSaveFile];
    _xmlHandler = [[XMLHandler alloc] init];
    _xmlHandler.delegate = self;
    [_xmlHandler parseXMLFileAt:[self getRootFilePath]];
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
#pragma mark - other methods
//set title for the view
- (void)settitleName:(NSString *)titleText{
    CGRect frame = CGRectMake(0, 0, 200, 44);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = titleText;
}
- (void)viewWillAppear:(BOOL)animated{
    [self performSelector:@selector(setBackButton) withObject:nil afterDelay:0.1];
}

- (void)setBackButton{
    UIBarButtonItem *objBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = objBarButtonItem;
    [objBarButtonItem release];
}

- (void)unzipAndSaveFile{
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za unzipOpenFile:[[NSBundle mainBundle] pathForResource:_strFileName ofType:@"epub"]]){
        NSString *strPath = [NSString stringWithFormat:@"%@/UnzippedEpub", [self applicationDocumentDirectory]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:strPath]){
            NSError *error;
            [fileManager removeItemAtPath:strPath error:&error];
        }
        [fileManager release];
        fileManager = nil;
        
        BOOL ret = [za unzipOpenFileTo:[NSString stringWithFormat:@"%@/", strPath] Overwrite:YES];
        if (NO == ret){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                            message:@"An unknown error occurred"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            alert = nil;
        }
        [za unzipCloseFile];
    }
    [za release];
}

//to find the path to document directory
- (NSString *)applicationDocumentDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath =([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//to find the path to contain .xml this file contains the file name which holds the epub information
- (NSString *)getRootFilePath{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *strFilePath = [NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml", [self applicationDocumentDirectory]];
    if ([fileManager fileExistsAtPath:strFilePath]){
        NSLog(@"Parse now");
        [fileManager release];
        fileManager = nil;
        return strFilePath;
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Root file not valid"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        alert = nil;
    }
    [fileManager release];
    fileManager = nil;
    return @"";
}

#pragma mark XMLHandler Delegate Methods
- (void)foundRootPath:(NSString *)rootPath{
    NSString *strOfFilePath = [NSString stringWithFormat:@"%@/UnzippedEpub/%@", [self applicationDocumentDirectory],
                               rootPath];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    self._rootPath = [strOfFilePath stringByReplacingOccurrencesOfString:[strOfFilePath lastPathComponent] withString:@""];
    if ([fileManager fileExistsAtPath:strOfFilePath]){
        [_xmlHandler parseXMLFileAt:strOfFilePath];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"OPF file not found"
                                                       delegate:self 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        alert = nil;
    }
    [fileManager release];
    fileManager = nil;
}

- (void)finishedParsing:(EpubContent *)ePubContents{
    _pagesPath = [NSString stringWithFormat:@"%@/%@", self._rootPath, [ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
    self._ePubContent = ePubContents;
    _pageNumber = 0;
    [self loadPage];
}

#pragma mark Button Actions
- (IBAction)onPrevOrNext:(id)sender{
    UIBarButtonItem *clickedButton = (UIBarButtonItem *)sender;
    if (clickedButton.tag == 0){
        if (_pageNumber > 0){
            _pageNumber --;
            [self loadPage];
        }
    }
    else {
        if ([self._ePubContent._spine count] - 1 > _pageNumber){
            _pageNumber ++;
            [self loadPage];
        }
    }
}

- (IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadPage{
    _pagesPath = [NSString stringWithFormat:@"%@/%@", self._rootPath, [self._ePubContent._manifest valueForKey:
                                                                       [self._ePubContent._spine objectAtIndex:_pageNumber]]];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
    pageNumberLbl.text = [NSString stringWithFormat:@"%d", _pageNumber + 1];
}


@end
