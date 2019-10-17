//
//  IPDFMacSheet.h
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPDFMacSheet : UIView

+ (instancetype)showSheetWithSizeHandler:(CGSize(^)(CGRect windowBounds))sizeHandler viewConfigurationHandler:(void(^)(UIView *contentView))viewConfigurationHandler;

+ (instancetype)currentSheet;

@property (nonatomic,copy) CGSize(^sizeHandler)(CGRect windowBounds);

- (void)dismissWithCompletionHandler:(void(^)(void))completionHandler;

+ (void)changeStateForToolbarItem:(NSToolbarItem *)toolbarItem stateAfterDismissal:(BOOL)stateAfterDismissal;

@end
