//
//  IPDFRightClickInteraction.h
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPDFRightClickInteraction : UIContextMenuInteraction

+ (instancetype)interactionForParentView:(UIView *)parentView rightClickHandler:(void(^)(void))rightClickHandler;

@end

NS_ASSUME_NONNULL_END
