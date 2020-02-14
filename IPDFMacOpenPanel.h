//
//  IPDFMacOpenPanel.h
//  Scanner
//
//  Created by mmackh on 14/02/2020.
//  Copyright © 2020 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPDFMacOpenPanel : NSObject

@property (nonatomic,copy) NSString *prompt;
@property (nonatomic,assign) BOOL allowsMultipleSelection;
@property (nonatomic,assign) BOOL canChooseDirectories;
@property (nonatomic,assign) BOOL canChooseFiles;
@property (nonatomic,assign) BOOL resolvesAliases;
@property (nonatomic,assign) BOOL accessoryViewDisclosed;

@property (nonatomic) NSArray *allowedFileTypes;

- (void)showPanelWithChosenFilesHandler:(void(^)(NSArray<NSURL*>*fileURLs))saveDataHandler;

@end

NS_ASSUME_NONNULL_END
