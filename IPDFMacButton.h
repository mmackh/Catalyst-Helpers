//
//  IPDFMacButton.h
//  InstaPDF for Mac
//
//  Created by mmackh on 14.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPDFMacButton : UIButton

+ (instancetype)buttonWithTitle:(NSString *)title clickHandler:(void(^)(IPDFMacButton *button))clickHandler;

@end
