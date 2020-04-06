//
//  IPDFMacButton.m
//  InstaPDF for Mac
//
//  Created by mmackh on 14.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFMacButton.h"

@interface NSColor_Catalyst : NSObject

- (instancetype)controlAccentColor;

@end

@interface IPDFMacButton ()

@property (nonatomic) void(^clickHandler)(IPDFMacButton *button);

@end

@implementation IPDFMacButton

+ (instancetype)buttonWithTitle:(NSString *)title clickHandler:(void(^)(IPDFMacButton *button))clickHandler
{
    IPDFMacButton *button = [IPDFMacButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    [button addTarget:button action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    
    button.clickHandler = clickHandler;
    
    [button updateColors];
    
    return button;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (NSArray<UIKeyCommand *> *)keyCommands
{
    return @[[UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:0 action:@selector(click:)]];
}

- (void)updateColors
{
    BOOL night = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    
    self.titleLabel.textColor = [UIColor labelColor];
    
    self.backgroundColor = night ? [UIColor colorWithRed:0.41 green:0.42 blue:0.44 alpha:1.00] : [UIColor systemBackgroundColor];
    
    self.layer.borderColor = [UIColor tertiaryLabelColor].CGColor;
    self.layer.borderWidth = 0.6;
    
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:1].CGColor;
    self.layer.shadowOpacity = 0.9;
    self.layer.shadowRadius = 0.5;
    
    self.layer.cornerRadius = 5;
}

- (void)setHighlighted:(BOOL)highlighted
{
    //[super setHighlighted:highlighted];
    if (highlighted)
    {
        self.backgroundColor = [NSClassFromString(@"NSColor") performSelector:@selector(controlAccentColor)];
        self.titleLabel.textColor = [UIColor whiteColor];
        return;
    }
    
    [self updateColors];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) return;
    
    CGRect targetRect = CGRectInset(self.bounds, 1, 0);
    targetRect.origin.y += 2;
    targetRect.size.height -= 2;
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:targetRect cornerRadius:5].CGPath;
    
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [self updateColors];
}

- (void)click:(IPDFMacButton *)button
{
    __weak typeof(self) weakSelf = self;
    if (self.clickHandler) self.clickHandler(weakSelf);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
