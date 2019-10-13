//
//  IPDFRightClickInteraction.m
//  InstaPDF for Mac
//
//  Created by mmackh on 13.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFRightClickInteraction.h"

@interface IPDFRightClickInteraction () <UIContextMenuInteractionDelegate>

@property (nonatomic,copy) void(^rightClickHandler)(void);

@end

@implementation IPDFRightClickInteraction

+ (instancetype)interactionForParentView:(UIView *)parentView rightClickHandler:(void(^)(void))rightClickHandler
{
    IPDFRightClickInteraction *clickInteraction = [[self class] interaction];
    [parentView addInteraction:clickInteraction];
    clickInteraction.rightClickHandler = rightClickHandler;
    return clickInteraction;
}

+ (instancetype)interaction
{
    id delegate = nil;
    IPDFRightClickInteraction *interaction = [[[self class] alloc] initWithDelegate:delegate];
    [interaction setValue:interaction forKey:@"delegate"];
    return interaction;
}

- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location
{
    if (self.rightClickHandler) self.rightClickHandler();
    return nil;
}

@end
