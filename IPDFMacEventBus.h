//
//  IPDFMacEventBus.h
//  InstaPDF for Mac
//
//  Created by mmackh on 18.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_MACCATALYST

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, IPDFMacEventBusType)
{
    IPDFMacEventBusTypeUnknown = 0,
    IPDFMacEventBusTypeKeydown = 1ULL << 10,
    IPDFMacEventBusTypeKeyup = 1ULL << 11,
    IPDFMacEventBusTypeFlagsChanged = 1ULL << 12,
    IPDFMacEventBusTypeSwipe = 1ULL << 31,
    IPDFMacEventBusTypeAppState = 1ULL << 1000,
};

typedef NS_ENUM(NSInteger, IPDFMacEventBusAppStateEvent)
{
    IPDFMacEventBusAppStateEventHide,
    IPDFMacEventBusAppStateEventUnhide,
    IPDFMacEventBusAppStateEventBecomeActive,
    IPDFMacEventBusAppStateEventResignActive,
    IPDFMacEventBusAppStateEventTerminate,
    IPDFMacEventBusAppStateEventScreenParameters,
};

@class IPDFMacEventBusMonitor;
@class IPDFMacEventBusEvent;

@interface IPDFMacEventBus : NSObject

+ (instancetype)sharedBus;

+ (IPDFMacEventBusEvent *)currentEvent;

- (void)addMonitor:(IPDFMacEventBusMonitor *)monitor;
- (void)removeMonitor:(IPDFMacEventBusMonitor *)monitor;

@end

@interface IPDFMacEventBusMonitor : NSObject

+ (instancetype)monitorWithType:(IPDFMacEventBusType)type eventHandler:(IPDFMacEventBusEvent * _Nullable (^)(IPDFMacEventBusEvent * event))eventHandler;

@property (nonatomic,assign) BOOL enabled;

@end

@interface IPDFMacEventBusEvent : NSObject

@property (nonatomic,readonly) IPDFMacEventBusType type;

@property (nonatomic,readonly) id underlyingEvent;

@end

@interface IPDFMacEventBusEvent (Keyboard)

- (NSString *)characters;
- (NSInteger)keyCode;

- (BOOL)isTab;
- (BOOL)isEnter;
- (BOOL)isESC;

- (BOOL)isArrowKey;
- (BOOL)isArrowUp;
- (BOOL)isArrowDown;
- (BOOL)isArrowRight;
- (BOOL)isArrowLeft;

- (BOOL)ctrlModifier;
- (BOOL)cmdModifier;
- (BOOL)shiftModifier;
- (BOOL)optionModifier;

@end

@interface IPDFMacEventBusEvent (Swipe)

- (CGFloat)deltaX;
- (CGFloat)deltaY;

@end

@interface IPDFMacEventBusEvent (AppState)

- (IPDFMacEventBusAppStateEvent)appState;

@end

NS_ASSUME_NONNULL_END

#endif
