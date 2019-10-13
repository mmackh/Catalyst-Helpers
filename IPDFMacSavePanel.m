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

@end

@implementation IPDFMacSavePanel

+ (void)showPanelWithFileName:(NSString *)fileName allowedFileExtensions:(NSArray *)allowedFileExtensions saveDataHandler:(void(^)(NSURL *targetURL))saveDataHandler
{
    NSSavePanel_Catalyst *savePanel = [NSClassFromString(@"NSSavePanel") savePanel];
    [savePanel setNameFieldStringValue:fileName];
    [savePanel setAllowedFileTypes:allowedFileExtensions];
    if ([savePanel runModal] == 1)
    {
        saveDataHandler(savePanel.URL);
    }
}

- (void)show
{
    
}

@end
