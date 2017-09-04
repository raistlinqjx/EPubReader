//
//  ZipArchive.m
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import "ZipArchive.h"
#import "zlib.h"
#import "zconf.h"

@interface ZipArchive (Private)
- (void)outputErrorMessage:(NSString *)msg;
- (BOOL)overwrite:(NSString *)file;
- (NSDate *)date1980;
@end

@implementation ZipArchive
@synthesize delegate = _delegate;

- (id)init{
    if ((self = [super init])){
        _unzipFile = NULL;
    }
    return self;
}

- (void)dealloc{
    [self closeZipFile2];
    [super dealloc];
}

- (BOOL)createZipFile2:(NSString *)zipFile{
    _zipFile = zipOpen((const char *)[zipFile UTF8String], 0);
    if (!_zipFile)
        return NO;
    return YES;
}

- (BOOL)createZipFile2:(NSString *)zipFile Password:(NSString *)psw{
    _password = psw;
    return [self createZipFile2:zipFile];
}

- (BOOL)addFileToZip:(NSString *)file newName:(NSString *)newName{
    if (!_zipFile)
        return NO;
    time_t current;
    time( &current);
    zip_fileinfo zipInfo = {0};
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
    if (attr){
        NSDate *fileDate = (NSDate *)[attr objectForKey:NSFileModificationDate];
        if (fileDate){
            NSCalendar *currCalender = [NSCalendar currentCalendar];
            uint flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
            NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dc = [currCalender components:flags fromDate:fileDate];
            zipInfo.tmz_date.tm_sec = [dc second];
            zipInfo.tmz_date.tm_min = [dc minute];
            zipInfo.tmz_date.tm_hour = [dc hour];
            zipInfo.tmz_date.tm_mday = [dc day];
            zipInfo.tmz_date.tm_mon = [dc month] - 1;
            zipInfo.tmz_date.tm_year = [dc year];
        }
    }
    
    int ret;
    NSData *data = nil;
    if ([_password length] == 0){
        ret = zipOpenNewFileInZip(_zipFile, (const char *)[newName UTF8String], &zipInfo,
                                  NULL, 0, NULL, 0, NULL, 
                                  Z_DEFLATED, Z_DEFAULT_COMPRESSION);
    }
    else {
        data = [NSData dataWithContentsOfFile:file];
        uLong crcValue = crc32(0L, NULL, 0L);
        crcValue = crc32(crcValue, (const Bytef *)[data bytes], [data length]);
        ret = zipOpenNewFileInZip3(_zipFile, (const char *)[newName UTF8String], &zipInfo,
                                   NULL, 0, NULL, 0, NULL,
                                   Z_DEFLATED, Z_DEFAULT_COMPRESSION,
                                   0,15, 8, Z_DEFAULT_STRATEGY,
                                   [_password cStringUsingEncoding:NSASCIIStringEncoding],
                                   crcValue);
    }
    if (ret != Z_OK)
        return NO;
    if (data == nil)
        data = [NSData dataWithContentsOfFile:file];
    unsigned int dataLen = [data length];
    ret = zipWriteInFileInZip(_zipFile, (const void *)[data bytes], dataLen);
    if (ret != Z_OK)
        return NO;
    ret = zipCloseFileInZip(_zipFile);
    if (ret != Z_OK)
        return NO;
    return  YES;
}

- (BOOL)closeZipFile2{
    _password = nil;
    if (_zipFile == NULL)
        return NO;
    BOOL ret = zipClose(_zipFile, NULL) == Z_OK ? YES : NO;
    _zipFile = NULL;
    return ret;
}

- (BOOL)unzipOpenFile:(NSString *)zipFile{
    _unzipFile = unzOpen((const char *)[zipFile UTF8String]);
    if (_unzipFile){
        unz_global_info globalInfo = {0};
        if (unzGetGlobalInfo(_unzipFile, &globalInfo) == Z_OK){
            NSLog(@"%lu entries in the zip file", globalInfo.number_entry);
        }
    }
    return _unzipFile != NULL;
}

- (BOOL)unzipOpenFile:(NSString *)zipFile Password:(NSString *)psw{
    _password = psw;
    return [self unzipOpenFile:zipFile];
}

- (BOOL)unzipOpenFileTo:(NSString *)path Overwrite:(BOOL)overwirte{
    BOOL success = YES;
    int ret = unzGoToFirstFile(_unzipFile);
    unsigned char buffer[4096] = {0};
    NSFileManager *fman = [NSFileManager defaultManager];
    if (ret != UNZ_OK)
        [self outputErrorMessage:@"failed"];
    do{
        if ([_password length] == 0)
            ret = unzOpenCurrentFile(_unzipFile);
        else
            ret = unzOpenCurrentFilePassword(_unzipFile, [_password cStringUsingEncoding:NSASCIIStringEncoding]);
        if (ret != UNZ_OK){
            [self outputErrorMessage:@"Error occurs"];
            success = NO;
            break;
        }
        int read;
        unz_file_info fileInfo = {0};
        ret = unzGetCurrentFileInfo(_unzipFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
        if (ret != UNZ_OK){
            [self outputErrorMessage:@"Error occurs while getting file info"];
            success = NO;
            unzCloseCurrentFile(_unzipFile);
            break;
        }
        char *fileName = (char *)malloc(fileInfo.size_filename + 1);
        unzGetCurrentFileInfo(_unzipFile, &fileInfo, fileName, fileInfo.size_filename + 1,
                              NULL, 0, NULL,0);
        fileName[fileInfo.size_filename] = '\0';
        //check if it contains directory
        NSString *strPath = [NSString stringWithCString:fileName encoding:NSUTF8StringEncoding];
        BOOL isDirectory = NO;
        if (fileName[fileInfo.size_filename - 1] == '/' || fileName[fileInfo.size_filename - 1] == '\\')
            isDirectory = YES;
        free(fileName);
        if ([strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location != NSNotFound)
            strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        NSString *fullPath = [path stringByAppendingPathComponent:strPath];
        if (isDirectory)
            [fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        else
            [fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES
            attributes:nil error:nil];
        if ([fman fileExistsAtPath:fullPath] && !isDirectory && !overwirte){
            if (! [self overwrite:fullPath]){
                unzCloseCurrentFile(_unzipFile);
                ret = unzGoToNextFile(_unzipFile);
                continue;
            }
        }
        FILE *fp = fopen((const char *)[fullPath UTF8String], "wb");
        while (fp){
            read = unzReadCurrentFile(_unzipFile, buffer, 4096);
            if (read > 0)
                fwrite(buffer, read, 1, fp);
            else if (read < 0){
                [self outputErrorMessage:@"Failed to reading zip file"];
                break;
            }
            else
                break;
        }
        if (fp){
            fclose(fp);
            NSDate *orgDate = nil;
            NSDateComponents *dc = [[NSDateComponents alloc] init];
            dc.second = fileInfo.tmu_date.tm_sec;
            dc.minute = fileInfo.tmu_date.tm_min;
            dc.hour = fileInfo.tmu_date.tm_hour;
            dc.day = fileInfo.tmu_date.tm_mday;
            dc.month = fileInfo.tmu_date.tm_mon + 1;
            dc.year = fileInfo.tmu_date.tm_year;
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            orgDate = [gregorian dateFromComponents:dc];
            [dc release];
            [gregorian release];
            
            NSDictionary *attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate];
            if (attr){
                if (![[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:fullPath error:nil]){
                    NSLog(@"failed to set attributes");
                }
            }
        }
        unzCloseCurrentFile(_unzipFile);
        ret = unzGoToNextFile(_unzipFile);
    }while (ret == UNZ_OK && UNZ_OK != UNZ_END_OF_LIST_OF_FILE) ;
    return success;
}
- (BOOL)unzipCloseFile{
    _password = nil;
    if (_unzipFile)
        return unzClose(_unzipFile) == UNZ_OK;
    return  YES;
}

#pragma mark wrapper for delegate
- (void)outputErrorMessage:(NSString *)msg{
    if (_delegate && [_delegate respondsToSelector:@selector(errorMessages)])
        [_delegate errorMessages:msg];
}

- (BOOL)overwrite:(NSString *)file{
    if (_delegate && [_delegate respondsToSelector:@selector(overwrite)])
        return [_delegate overwrite:file];
    return YES;
}

#pragma mark get NSDate object for 19800101
- (NSDate *)date1980{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:1980];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    [comps release];
    [gregorian release];
    return date;
}
@end
