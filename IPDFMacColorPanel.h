//
//  IPDFMacColorPanel.h
//  InstaPDF for Mac
//
//  Created by mmackh on 15.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPDFMacColorPanel : NSObject

+ (void)showColorPanelWithColorChangeHandler:(void(^)(UIColor *color))colorChangeHandler;

/// Hides the color picker panel and removes the colorChangeHandler observer
+ (void)hide;

+ (void)removeColorChangeHandlerObserver;

@end
