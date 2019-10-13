//
//  IPDFContextMenu.h
//  InstaPDF
//
//  Created by Maximilian Mackh on 02/02/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPDFContextMenu : NSObject

+ (instancetype)menuWithActions:(NSArray *)actions;

- (void)show;

@end

@interface IPDFContextMenuAction : NSObject

+ (instancetype)actionWithSeparator;
+ (instancetype)actionWithTitle:(NSString *)title handler:(void(^)(void))handler;
+ (instancetype)actionWithTitle:(NSString *)title keyEquivilant:(NSString *)keyEquivilant modifierMask:(NSUInteger)modifierMask handler:(void(^)(void))handler;

@property (nonatomic, assign) BOOL disableItem;

+ (NSString *)backspaceCharacter;

@end

NS_ASSUME_NONNULL_END
