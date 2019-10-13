//
//  IPDFMacSavePanel.m
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFMacSavePanel.h"

@interface NSSavePanel_Catalyst : NSObject

+ (instancetype)savePanel;

@property (nonatomic) NSString *nameFieldStringValue;
@property (nonatomic) NSArray *allowedFileTypes;

@property (nonatomic,readonly) NSURL *URL;

- (NSInteger)runModal;

- (void)beginSheetModalForWindow:(id)sheetWindow completionHandler:(void (^)(NSInteger returnCode))handler;

@end

@implementation IPDFMacSavePanel

+ (void)showPanelWithFileName:(NSString *)fileName allowedFileExtensions:(NSArray *)allowedFileExtensions saveDataHandler:(void(^)(NSURL *targetURL))saveDataHandler
{
    NSSavePanel_Catalyst *savePanel = [NSClassFromString(@"NSSavePanel") savePanel];
    [savePanel setNameFieldStringValue:fileName];
    [savePanel setAllowedFileTypes:allowedFileExtensions];
    
    id app = [NSClassFromString(@"NSApplication") performSelector:@selector(sharedApplication)];
    id keyWindow = [app performSelector:@selector(keyWindow)];
    if (!keyWindow) return;
    
    __weak typeof(savePanel) weakSavePanel = savePanel;
    
    [savePanel beginSheetModalForWindow:keyWindow completionHandler:^(NSInteger returnCode)
    {
        saveDataHandler(weakSavePanel.URL);
    }];
}

- (void)show
{
    
}

@end
