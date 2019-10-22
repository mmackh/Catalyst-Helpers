//
//  IPDFToolbarHelper.m
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFToolbarHelper.h"

#import <UIKit/NSToolbar+UIKitAdditions.h>

@class NSSearchField_Catalyst;

@protocol NSSearchFieldDelegate_Catalyst

@optional
- (void)searchFieldDidStartSearching:(NSSearchField_Catalyst *)sender;
- (void)searchFieldDidEndSearching:(NSSearchField_Catalyst *)sender;

@required
- (void)controlTextDidChange:(NSNotification *)notification;

@end

@interface NSUIWindow_Catalyst : NSObject

- (void)makeFirstResponder:(id)obj;

@end

@interface NSSearchField_Catalyst : NSObject

@property(weak) id<NSSearchFieldDelegate_Catalyst> delegate;

@property (nonatomic,readwrite) NSString *stringValue;

@end

@interface NSToolbarItem_Catalyst () <NSSearchFieldDelegate_Catalyst>

@property (nonatomic,copy) void(^textDidChangeHandler)(NSString *stringValue);

@property id image;
@property id imageStore;

@end

@implementation NSToolbarItem_Catalyst

@dynamic view;
@dynamic minSize;
@dynamic maxSize;

@dynamic image;

+ (instancetype)searchItemWithItemIdentifier:(NSString *)itemIdentifier textDidChangeHandler:(void(^)(NSString *stringValue))textDidChangeHandler
{
    NSToolbarItem_Catalyst *toolbarItem = [[[self class] alloc] initWithItemIdentifier:itemIdentifier];
    
    NSSearchField_Catalyst *searchField = [NSClassFromString(@"NSSearchField") new];
    searchField.delegate = toolbarItem;
    toolbarItem.view = searchField;
    toolbarItem.maxSize = CGSizeMake(240, 44);
    toolbarItem.textDidChangeHandler = textDidChangeHandler;
    toolbarItem.paletteLabel = @"Search";
    return toolbarItem;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSSearchField_Catalyst *searchField = notification.object;
    if (self.textDidChangeHandler) self.textDidChangeHandler(searchField.stringValue);
}

- (void)setSearchFieldStringValue:(NSString *)searchFieldStringValue
{
    if (![self.view isKindOfClass:NSClassFromString(@"NSSearchField")]) return;
    NSSearchField_Catalyst *searchField = self.view;
    searchField.stringValue = searchFieldStringValue;
}

- (NSString *)searchFieldStringValue
{
    if (![self.view isKindOfClass:NSClassFromString(@"NSSearchField")]) return @"";
    NSSearchField_Catalyst *searchField = self.view;
    return searchField.stringValue;
}

- (void)searchItemBecomeFirstResponder
{
    [[self.view window] performSelector:@selector(makeFirstResponder:) withObject:self.view];
}

@end

@implementation NSToolbar_Catalyst

@dynamic sizeMode;

@end

@implementation IPDFToolbarHelper

@end
