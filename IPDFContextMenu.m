//
//  IPDFContextMenu.m
//  InstaPDF
//
//  Created by Maximilian Mackh on 02/02/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import "IPDFContextMenu.h"

@interface NSMenu_Catalyst : NSObject

@property (nonatomic) BOOL autoenablesItems;
- (void)addItem:(id)item;

+ (void)popUpContextMenu:(id)menu withEvent:(id)event forView:(id)view;

- (id)currentEvent;

@property (nonatomic) BOOL allowsContextMenuPlugIns;

@end

@interface NSMenuItem_Catalyst : NSObject

+ (instancetype)separatorItem;

- (instancetype)initWithTitle:(NSString *)title action:(nonnull SEL)action keyEquivalent:(NSString *)keyEquivilant;

- (void)setTarget:(id)target;
- (void)setKeyEquivalentModifierMask:(NSInteger)keyEquivalentModifierMask;

@property (nonatomic) BOOL enabled;

@end

typedef void(^IPDFContextMenuActionHandler)(void);

@interface IPDFContextMenuAction ()

@property (nonatomic,strong) IPDFContextMenuActionHandler handler;
@property (nonatomic) NSMenuItem_Catalyst *attachedItem;

@end

@interface IPDFContextMenu ()

@property (nonatomic) NSArray *actions;
@property (nonatomic) NSMenu_Catalyst *attachedMenu;

@end

@implementation IPDFContextMenu

+ (instancetype)menuWithActions:(NSArray *)actions
{
    IPDFContextMenu *cM = [IPDFContextMenu new];
    cM.actions = actions;
    cM.attachedMenu = [[NSClassFromString(@"NSMenu") alloc] init];
    cM.attachedMenu.autoenablesItems = NO;
    cM.attachedMenu.allowsContextMenuPlugIns = NO;
    for (IPDFContextMenuAction *action in actions)
    {
        [cM.attachedMenu addItem:action.attachedItem];
    }
    return cM;
}

- (void)setAllowsContextMenuPlugIns:(BOOL)allowsContextMenuPlugIns
{
    _allowsContextMenuPlugIns = allowsContextMenuPlugIns;
    self.attachedMenu.allowsContextMenuPlugIns = allowsContextMenuPlugIns;
}

- (void)show
{
    id app = [NSClassFromString(@"NSApplication") performSelector:@selector(sharedApplication)];
    id keyWindow = [app performSelector:@selector(keyWindow)];
    if (!keyWindow) return;
    id currentEvent = [keyWindow performSelector:@selector(currentEvent)];
    
    [NSClassFromString(@"NSMenu") popUpContextMenu:self.attachedMenu withEvent:currentEvent forView:nil];
}

@end

@implementation IPDFContextMenuAction

+ (instancetype)actionWithSeparator
{
    IPDFContextMenuAction *cMA = [IPDFContextMenuAction new];
    cMA.attachedItem = [NSClassFromString(@"NSMenuItem") separatorItem];
    return cMA;
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(void(^)(void))handler
{
    return [self actionWithTitle:title keyEquivilant:@"" modifierMask:0 handler:handler];
}

+ (instancetype)actionWithTitle:(NSString *)title keyEquivilant:(NSString *)keyEquivilant modifierMask:(NSUInteger)modifierMask handler:(void(^)(void))handler;
{
    IPDFContextMenuAction *cMA = [IPDFContextMenuAction new];
    cMA.attachedItem = [[NSClassFromString(@"NSMenuItem") alloc] initWithTitle:title action:@selector(action) keyEquivalent:keyEquivilant];
    [cMA.attachedItem setTarget:cMA];
    [cMA.attachedItem setKeyEquivalentModifierMask:modifierMask];
    cMA.handler = handler;
    return cMA;
}

- (void)action
{
    if(self.handler) self.handler();
}

- (void)setDisableItem:(BOOL)disableItem
{
    self.attachedItem.enabled = !disableItem;
}

+ (NSString *)backspaceCharacter
{
    unichar backspaceChar = 0x0008;
    return [NSString stringWithCharacters:&backspaceChar length:1];
}

@end
