//
//  ZipArchive.h
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "zip.h"
#include "unzip.h"

@protocol ZipArchiveDelegate <NSObject>
@optional
- (void)errorMessages:(NSString *)msg;
- (BOOL)overWriteOperation:(NSString *)file;
@end

@interface ZipArchive : NSObject{
@private
    zipFile _zipFile;
    unzFile _unzipFile;
    NSString *_password;
    id _delegate;
}
@property (nonatomic, retain) id delegate;
- (BOOL)createZipFile2:(NSString *)zipFile;
- (BOOL)createZipFile2:(NSString *)zipFile Password:(NSString *)psw;
- (BOOL)addFileToZip:(NSString *)file newName:(NSString *)newName;
- (BOOL)closeZipFile2;

- (BOOL)unzipOpenFile:(NSString *)zipFile;
- (BOOL)unzipOpenFile:(NSString *)zipFile Password:(NSString *)psw;
- (BOOL)unzipOpenFileTo:(NSString *)path Overwrite:(BOOL)overwirte;
- (BOOL)unzipCloseFile;
@end
