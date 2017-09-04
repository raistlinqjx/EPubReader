//
//  XMLHandler.m
//  EPubReader
//
//  Created by apple QJX on 12-6-8.
//  Copyright (c) 2012年 HZNetquick. All rights reserved.
//

#import "XMLHandler.h"

@implementation XMLHandler
@synthesize delegate;

- (void)parseXMLFileAt:(NSString *)path{
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    _parser.delegate = self;
    [_parser parse];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"Error occurred: %@", [parseError description]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"rootfile"]){
        _rootPath = [attributeDict valueForKey:@"full-path"];
        if ((delegate != nil) && ([delegate respondsToSelector:@selector(foundRootPath:)])){
            [delegate foundRootPath:_rootPath];
        }
    }
    
    if ([elementName isEqualToString:@"package"])
        _ePubContent = [[EpubContent alloc] init];
    if ([elementName isEqualToString:@"manifest"])
        _itemDictionary = [[NSMutableDictionary alloc] init];
    if ([elementName isEqualToString:@"item"])
        [_itemDictionary setValue:[attributeDict valueForKey:@"href"] forKey:[attributeDict valueForKey:@"id"]];
    if ([elementName isEqualToString:@"spine"])
        _spineArray = [[NSMutableArray alloc] init];
    if ([elementName isEqualToString:@"itemref"])
        [_spineArray addObject:[attributeDict valueForKey:@"idref"]];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"manifest"])
        _ePubContent._manifest = _itemDictionary;
    if ([elementName isEqualToString:@"spine"])
        _ePubContent._spine = _spineArray;
    if ([elementName isEqualToString:@"package"]){
        if ((delegate != nil) && ([delegate respondsToSelector:@selector(finishedParsing:)]))
            [delegate finishedParsing:_ePubContent];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{}
@end
