//
//  IPDFMacSheet.m
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFMacSheet.h"

@interface NSWindow_Catalyst : NSObject

- (void)beginSheet:(id)sheet completionHandler:(id)completionHandler;
@property id contentView;
@property CGSize contentSize;

@end

@interface IPDFMacSheetToolbarItemState : NSObject

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL autovalidates;

@end @implementation IPDFMacSheetToolbarItemState @end

@interface IPDFMacSheet ()

@property (nonatomic) UIView *backgroundView;

@property (nonatomic) NSMutableDictionary<NSNumber *,IPDFMacSheetToolbarItemState *> *toolbarItemStates;

@end

@implementation IPDFMacSheet

+ (UIWindow *)targetWindow
{
    return [UIApplication sharedApplication].windows.firstObject;
}

+ (instancetype)showSheetWithSizeHandler:(CGSize(^)(CGRect windowBounds))sizeHandler viewConfigurationHandler:(void(^)(UIView *contentView))viewConfigurationHandler
{
    UIWindow *targetWindow = [self targetWindow];
    
    IPDFMacSheet *sheet = [[self class] new];
    
    UIEdgeInsets safeAreaInsets = targetWindow.safeAreaInsets;
    
    CGRect windowBounds = targetWindow.frame;
    windowBounds.origin.y = safeAreaInsets.top;
    windowBounds.size.height -= safeAreaInsets.top;
    sheet.backgroundView = [[UIView alloc] initWithFrame:windowBounds];
    sheet.backgroundView.backgroundColor = [UIColor clearColor];
    sheet.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [targetWindow addSubview:sheet.backgroundView];
    
    sheet.sizeHandler = sizeHandler;
    
    CGSize sheetSize = sizeHandler(windowBounds);
    CGRect targetSheetFrame = windowBounds;
    targetSheetFrame.size = sheetSize;
    targetSheetFrame.origin.x = windowBounds.size.width / 2 - sheetSize.width/2;
    targetSheetFrame.origin.y = -targetSheetFrame.size.height;
    sheet.frame = targetSheetFrame;
    sheet.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    targetSheetFrame.origin.y = safeAreaInsets.top - 1;

    UIVisualEffectView *backgroundBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial]];
    backgroundBlurView.frame = sheet.bounds;
    backgroundBlurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [sheet addSubview:backgroundBlurView];
    
    sheet.layer.borderColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.74 alpha:1.00].CGColor;
    sheet.layer.borderWidth = 1.0;
    
    sheet.layer.shadowColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    sheet.layer.shadowRadius = 8;
    sheet.layer.shadowOffset = CGSizeZero;
    sheet.layer.shadowOpacity = 0.5;
    
    [targetWindow addSubview:sheet];
    
    viewConfigurationHandler(sheet);
    
    [UIView animateWithDuration:0.4 animations:^
    {
        sheet.backgroundView.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.15];
        sheet.frame = targetSheetFrame;
    }];
    
    return sheet;
}

+ (instancetype)currentSheet
{
    UIWindow *targetWindow = [self targetWindow];
    
    for (UIView *subview in targetWindow.subviews)
    {
        if ([subview isKindOfClass:[self class]])
        {
            return (id)subview;
        }
    }
    
    return nil;
}

- (void)dismissWithCompletionHandler:(void (^)(void))completionHandler
{
    self.sizeHandler = nil;
    
    CGRect targetSheetFrame = self.frame;
    targetSheetFrame.origin.y = -targetSheetFrame.size.height;
    
    [UIView animateWithDuration:0.4 animations:^
    {
        self.frame = targetSheetFrame;
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    completion:^(BOOL finished)
    {
        if (completionHandler) completionHandler();
        
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.sizeHandler) return;
    
    CGSize targetSize = self.sizeHandler(self.backgroundView.bounds);
    CGRect targetFrame = self.frame;
    targetFrame.origin.x = self.backgroundView.bounds.size.width / 2 - targetSize.width/2;
    targetFrame.size = targetSize;
    
    self.frame = targetFrame;
}

- (void)setDisableToolbar:(BOOL)disableToolbar
{
    _disableToolbar = disableToolbar;
    
    if (!self.toolbarItemStates)
    {
        self.toolbarItemStates = [NSMutableDictionary new];
    }
    
    UIWindowScene *scene = self.window.windowScene;
    [scene.titlebar.toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    NSInteger idx = 0;
    for (NSToolbarItem *toolbarItem in scene.titlebar.toolbar.items)
    {
        BOOL autovalidates = !disableToolbar;
        BOOL enabled = !disableToolbar;
        
        if (disableToolbar)
        {
            IPDFMacSheetToolbarItemState *state = [IPDFMacSheetToolbarItemState new];
            state.autovalidates = toolbarItem.autovalidates;
            state.enabled = toolbarItem.enabled;
            self.toolbarItemStates[@(idx)] = state;
        }
        else
        {
            IPDFMacSheetToolbarItemState *state = self.toolbarItemStates[@(idx)];
            autovalidates = state.autovalidates;
            enabled = state.enabled;
        }
        
        toolbarItem.autovalidates = autovalidates;
        toolbarItem.enabled = enabled;
        
        idx += 1;
    }
}

@end
