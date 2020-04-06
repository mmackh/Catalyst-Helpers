//
//  IPDFMacEventBus.h
//  InstaPDF for Mac
//
//  Created by mmackh on 18.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned long long, IPDFMacEventBusType)
{
    IPDFMacEventBusTypeKeydown = 1ULL << 10,
    IPDFMacEventBusTypeAppState = 2ULL << 10
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

- (void)addMonitor:(IPDFMacEventBusMonitor *)monitor;
- (void)removeMonitor:(IPDFMacEventBusMonitor *)monitor;

@end

@interface IPDFMacEventBusMonitor : NSObject

+ (instancetype)monitorWithType:(IPDFMacEventBusType)type eventHandler:(IPDFMacEventBusEvent *(^)(IPDFMacEventBusEvent *event))eventHandler;

@property (nonatomic,assign) BOOL enabled;

@end

@interface IPDFMacEventBusEvent : NSObject

@property (nonatomic,readonly) IPDFMacEventBusType type;

@property (nonatomic,readonly) id underlyingEvent;

@end

@interface IPDFMacEventBusEvent (Keyboard)

- (NSString *)characters;

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

@end

@interface IPDFMacEventBusEvent (AppState)

- (IPDFMacEventBusAppStateEvent)appState;

@end
