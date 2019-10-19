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
@property (readonly, copy) NSString *characters;

@end

@interface IPDFMacEventBusEvent ()

@property (nonatomic,readwrite) IPDFMacEventBusType type;
@property (nonatomic,readwrite) NSString *characters;

@property (nonatomic,readwrite) NSEvent_Catalyst *underlyingEvent;

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

- (void)addMonitor:(IPDFMacEventBusMonitor *)monitor
{
    NSEvent_Catalyst *class = (id)NSClassFromString(@"NSEvent");
    __weak typeof(monitor) weakMonitor = monitor;
    monitor.eventMonitor = [class addLocalMonitorForEventsMatchingMask:monitor.type handler:^id(NSEvent_Catalyst *event)
    {
        if (!weakMonitor.enabled) return event;
        
        IPDFMacEventBusEvent *busEvent = [IPDFMacEventBusEvent new];
        busEvent.type = weakMonitor.type;
        busEvent.underlyingEvent = event;
        return weakMonitor.eventHandler(busEvent).underlyingEvent;
    }];
    [self.monitorsMutable addObject:monitor];
}

- (void)removeMonitor:(IPDFMacEventBusMonitor *)monitor
{
    NSEvent_Catalyst *class = (id)NSClassFromString(@"NSEvent");
    [class removeMonitor:monitor.eventMonitor];
    monitor.eventMonitor = nil;
    monitor.eventHandler = nil;
    monitor.enabled = NO;
    [self.monitorsMutable removeObject:monitor];
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
    return [self.characters isEqualToString:@"\r"];
}

- (BOOL)isESC
{
    return self.underlyingEvent.keyCode == 0x35;
}

@end
