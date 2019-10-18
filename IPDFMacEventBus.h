//
//  IPDFMacKeyBus.h
//  InstaPDF for Mac
//
//  Created by mmackh on 18.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IPDFMacEventBusType)
{
    IPDFMacEventBusTypeKeydown
};

@class IPDFMacEventBusMontior;
@class IPDFMacEventBusEvent;

@interface IPDFMacEventBus : NSObject

+ (instancetype)sharedBus;

- (void)addMontior:(IPDFMacEventBusMontior *)monitor;
- (void)removeMonditor:(IPDFMacEventBusMontior *)monitor;

@end

@interface IPDFMacEventBusMontior : NSObject

+ (instancetype)monitorWithType:(IPDFMacEventBusType)type eventHandler:(IPDFMacEventBusEvent *(^)(IPDFMacEventBusEvent *event))eventHandler;

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

@end
