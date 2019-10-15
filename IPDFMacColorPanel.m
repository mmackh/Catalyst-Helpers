//
//  IPDFMacColorPanel.m
//  InstaPDF for Mac
//
//  Created by mmackh on 15.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFMacColorPanel.h"

@interface NSColorPanel_Catalyst : NSObject

+ (instancetype)sharedColorPanel;

- (void)makeKeyAndOrderFront:(id)sender;
- (void)orderOut:(id)sender;

- (void)setTarget:(id)target;
- (void)setAction:(SEL)action;

- (UIColor *)color;

@end

@interface IPDFMacColorPanel ()

@property (nonatomic,copy) void(^colorChangeHandler)(UIColor *color);

@end

@implementation IPDFMacColorPanel

+ (instancetype)sharedPanel
{
    static IPDFMacColorPanel *panel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        panel = [IPDFMacColorPanel new];
    });
    return panel;
}

+ (NSColorPanel_Catalyst *)colorPanel
{
    return [NSClassFromString(@"NSColorPanel") performSelector:@selector(sharedColorPanel)];
}

+ (void)showColorPanelWithColorChangeHandler:(void(^)(UIColor *color))colorChangeHandler
{
    IPDFMacColorPanel *observer = [IPDFMacColorPanel sharedPanel];
    observer.colorChangeHandler = colorChangeHandler;
    
    NSColorPanel_Catalyst *colorPanel = [self colorPanel];
    [colorPanel setTarget:observer];
    [colorPanel setAction:@selector(colorChange:)];
    [colorPanel makeKeyAndOrderFront:nil];
}

+ (void)hide
{
    [[self colorPanel] orderOut:nil];
    [self removeColorChangeHandlerObserver];
}

+ (void)removeColorChangeHandlerObserver
{
    [IPDFMacColorPanel sharedPanel].colorChangeHandler = nil;
}

- (void)colorChange:(NSColorPanel_Catalyst *)colorPanel
{
    if (self.colorChangeHandler) self.colorChangeHandler(colorPanel.color);
}

@end
