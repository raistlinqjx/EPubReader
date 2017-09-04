//
//  XMLHandler.h
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EpubContent.h"

@protocol XMLHandlerDelegate <NSObject>
@optional
- (void)foundRootPath:(NSString *)rootPath;
- (void)finishedParsing:(EpubContent *)ePubContents;
@end

@interface XMLHandler : NSObject<NSXMLParserDelegate>{
    NSXMLParser *_parser;
    NSString *_rootPath;
    id<XMLHandlerDelegate> delegate;
    EpubContent *_ePubContent;
    NSMutableArray *_spineArray;
    NSMutableDictionary *_itemDictionary;
}
@property (nonatomic, retain) id<XMLHandlerDelegate> delegate;
- (void)parseXMLFileAt:(NSString *)path;
@end
