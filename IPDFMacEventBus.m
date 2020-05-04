//
//  IPDFMacEventBus.m
//  InstaPDF for Mac
//
//  Created by mmackh on 18.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFMacEventBus.h"

@interface NSEvent_Catalyst : NSObject

- (id)addLocalMonitorForEventsMatchingMask:(long)mask handler:(id _Nullable (^)(id))block;
- (void)removeMonitor:(id)eventMonitor;

@property (readonly) unsigned short keyCode;
@property (readonly,copy) NSString *characters;

@property (readonly) NSUInteger modifierFlags;

@end

@interface IPDFMacEventBusEvent ()

@property (nonatomic,readwrite) IPDFMacEventBusType type;

@property (nonatomic,readwrite) NSEvent_Catalyst *underlyingEvent;

@property (nonatomic,readwrite) IPDFMacEventBusAppStateEvent appStateEvent;

@end

@interface IPDFMacEventBusMonitor ()

@property (nonatomic) IPDFMacEventBusType type;
@property (nonatomic, copy) IPDFMacEventBusEvent *(^eventHandler)(IPDFMacEventBusEvent *event);

@property (nonatomic) id eventMonitor;

@end

@interface IPDFMacEventBus ()

@property (nonatomic) NSMutableArray *monitorsMutable;

@end

@implementation IPDFMacEventBus

+ (instancetype)sharedBus
{
    static IPDFMacEventBus *bus = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        bus = [IPDFMacEventBus new];
        bus.monitorsMutable = [NSMutableArray new];
    });
    return bus;
}

+ (IPDFMacEventBusEvent *)currentEvent
{
    id app = [NSClassFromString(@"NSApplication") performSelector:@selector(sharedApplication)];
    id keyWindow = [app performSelector:@selector(keyWindow)];
    if (!keyWindow) return nil;
    id currentEvent = [keyWindow performSelector:@selector(currentEvent)];
    
    IPDFMacEventBusEvent *event =  [IPDFMacEventBusEvent new];
    event.underlyingEvent = currentEvent;
    event.type  = IPDFMacEventBusTypeUnknown;
    return event;
}

- (void)addMonitor:(IPDFMacEventBusMonitor *)monitor
{
    NSEvent_Catalyst *class = (id)NSClassFromString(@"NSEvent");
    __weak typeof(monitor) weakMonitor = monitor;
    
    if (monitor.type == IPDFMacEventBusTypeAppState)
    {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [[IPDFMacEventBus appStateEventsMap] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop)
        {
            [notificationCenter addObserver:self selector:@selector(appStateEventNotification:) name:key object:nil];
        }];
    }
    else
    {
        
        monitor.eventMonitor = [class addLocalMonitorForEventsMatchingMask:monitor.type handler:^id(NSEvent_Catalyst *event)
        {
            if (!weakMonitor.enabled) return event;
            
            IPDFMacEventBusEvent *busEvent = [IPDFMacEventBusEvent new];
            busEvent.type = weakMonitor.type;
            busEvent.underlyingEvent = event;
            return weakMonitor.eventHandler(busEvent).underlyingEvent;
        }];
    }
    [self.monitorsMutable addObject:monitor];
}

- (void)removeMonitor:(IPDFMacEventBusMonitor *)monitor
{
    if (monitor.type == IPDFMacEventBusTypeAppState)
    {
        monitor.enabled = NO;
        monitor.eventHandler = nil;
        [self.monitorsMutable removeObject:monitor];
        
        BOOL foundAppStateMonitor = NO;
        for (IPDFMacEventBusMonitor *activeMonitor in self.monitorsMutable)
        {
            if (activeMonitor.type == IPDFMacEventBusTypeAppState)
            {
                foundAppStateMonitor = YES;
                break;
            }
        }
        
        if (!foundAppStateMonitor)
        {
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [[IPDFMacEventBus appStateEventsMap] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop)
            {
                [notificationCenter removeObserver:self name:key object:nil];
            }];
        }
        
        return;
    }
    
    NSEvent_Catalyst *class = (id)NSClassFromString(@"NSEvent");
    [class removeMonitor:monitor.eventMonitor];
    monitor.eventMonitor = nil;
    monitor.eventHandler = nil;
    monitor.enabled = NO;
    [self.monitorsMutable removeObject:monitor];
}

- (void)appStateEventNotification:(NSNotification *)notification
{
    IPDFMacEventBusAppStateEvent appStateEvent = [[IPDFMacEventBus appStateEventsMap][notification.name] integerValue];
    IPDFMacEventBusEvent *event = [IPDFMacEventBusEvent new];
    event.appStateEvent = appStateEvent;
    event.underlyingEvent = (id)notification;
    
    for (IPDFMacEventBusMonitor *monitor in self.monitorsMutable)
    {
        if (monitor.type != IPDFMacEventBusTypeAppState) continue;
        if (!monitor.enabled) continue;
        
        monitor.eventHandler(event);
    }
}

#pragma mark -
#pragma mark Helpers

+ (NSDictionary *)appStateEventsMap
{
    static NSDictionary *appStateEventsMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        appStateEventsMap =
        @{
            @"NSApplicationWillHideNotification" : @(IPDFMacEventBusAppStateEventHide),
            @"NSApplicationWillUnhideNotification" : @(IPDFMacEventBusAppStateEventUnhide),
            @"NSApplicationWillBecomeActiveNotification" : @(IPDFMacEventBusAppStateEventBecomeActive),
            @"NSApplicationWillResignActiveNotification" : @(IPDFMacEventBusAppStateEventResignActive),
            @"NSApplicationWillTerminateNotification" : @(IPDFMacEventBusAppStateEventTerminate),
            @"NSApplicationDidChangeScreenParametersNotification" : @(IPDFMacEventBusAppStateEventScreenParameters),
        };
    });
    return appStateEventsMap;
}

@end

@implementation IPDFMacEventBusMonitor

+ (instancetype)monitorWithType:(IPDFMacEventBusType)type eventHandler:(IPDFMacEventBusEvent *(^)(IPDFMacEventBusEvent *event))eventHandler
{
    IPDFMacEventBusMonitor *monitor = [IPDFMacEventBusMonitor new];
    monitor.type = type;
    monitor.eventHandler = eventHandler;
    monitor.enabled = YES;
    return monitor;
}

@end

@implementation IPDFMacEventBusEvent

@end

@implementation IPDFMacEventBusEvent (Keyboard)

- (NSString *)characters
{
    return [(NSEvent_Catalyst *)self.underlyingEvent characters];
}

- (BOOL)isTab
{
    return [self.characters isEqualToString:@"\t"];
}

- (BOOL)isEnter
{
    return [self.characters isEqualToString:@"\r"] || self.underlyingEvent.keyCode == 76;
}

- (BOOL)isESC
{
    return self.underlyingEvent.keyCode == 53;
}

- (BOOL)isArrowKey
{
    return (self.isArrowUp || self.isArrowDown || self.isArrowRight || self.isArrowLeft);
}

- (BOOL)isArrowUp
{
    return self.underlyingEvent.keyCode == 126;
}

- (BOOL)isArrowDown
{
    return self.underlyingEvent.keyCode == 125;
}

- (BOOL)isArrowRight
{
    return self.underlyingEvent.keyCode == 124;
}

- (BOOL)isArrowLeft
{
    return self.underlyingEvent.keyCode == 123;
}


- (BOOL)ctrlModifier
{
    NSUInteger NSEventModifierFlagControl = 1 << 18;
    return (self.underlyingEvent.modifierFlags & NSEventModifierFlagControl) > 0;
}

- (BOOL)cmdModifier
{
    NSUInteger NSEventModifierFlagCommand = 1 << 20;
    return (self.underlyingEvent.modifierFlags & NSEventModifierFlagCommand) > 0;
}

@end

@implementation IPDFMacEventBusEvent (AppState)

- (IPDFMacEventBusAppStateEvent)appState
{
    return _appStateEvent;
}

@end
