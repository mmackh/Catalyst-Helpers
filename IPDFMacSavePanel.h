//
//  IPDFMacSavePanel.h
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPDFMacSavePanel : NSObject

+ (void)showPanelWithFileName:(NSString *)fileName allowedFileExtensions:(NSArray *)allowedFileExtensions saveDataHandler:(void(^)(NSURL *targetURL))saveDataHandler;

@end

NS_ASSUME_NONNULL_END
