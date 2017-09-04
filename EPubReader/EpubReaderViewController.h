//
//  EpubReaderViewController.h
//  EPubReader
//
//  Created by apple QJX on 12-6-12.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "XMLHandler.h"
#import "EpubContent.h"
@interface EpubReaderViewController : UIViewController<XMLHandlerDelegate>{
    IBOutlet UIWebView *_webView;
    IBOutlet UIImageView *_backGroundImage;
    IBOutlet UILabel *pageNumberLbl;
    XMLHandler *_xmlHandler;
    EpubContent *_ePubContent;
    NSString *_pagesPath;
    NSString *_rootPath;
    NSString *_strFileName;
    int _pageNumber;
}
@property (nonatomic, retain) EpubContent *_ePubContent;
@property (nonatomic, retain) NSString *_rootPath;
@property (nonatomic, retain) NSString *_strFileName;

- (void)unzipAndSaveFile;
- (NSString *)applicationDocumentDirectory;
- (void)loadPage;
- (NSString *)getRootFilePath;
- (void)settitleName:(NSString *)titleText;
- (void)setBackButton;
- (IBAction)onPrevOrNext:(id)sender;
@end
