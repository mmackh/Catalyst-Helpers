//
//  IPDFToolbarHelper.h
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSToolbarItem_Catalyst : NSToolbarItem

@property id view;

@property CGSize minSize;
@property CGSize maxSize;

+ (instancetype)searchItemWithItemIdentifier:(NSString *)itemIdentifier textDidChangeHandler:(void(^)(NSString *stringValue))textDidChangeHandler;

@property (nonatomic) NSString *searchFieldStringValue;
- (void)searchItemBecomeFirstResponder;

@end

@interface NSToolbar_Catalyst : NSToolbar

@property NSToolbarSizeMode sizeMode;

@end

@interface IPDFToolbarHelper : NSObject

@end

NS_ASSUME_NONNULL_END
