//
//  IPDFMacSecureTextField.m
//  InstaPDF for Mac
//
//  Created by mmackh on 20.10.19.
//  Copyright © 2019 mackh ag. All rights reserved.
//

#import "IPDFMacSecureTextField.h"

@interface IPDFMacSecureTextField ()

@property (nonatomic) UIFont *backupFont;

@end

@implementation IPDFMacSecureTextField

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    return self;
}

- (void)setSecureTextEntryWithoutAutofill:(BOOL)secureTextEntryWithoutAutofill
{
    _secureTextEntryWithoutAutofill = secureTextEntryWithoutAutofill;
    
    if (secureTextEntryWithoutAutofill)
    {
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.accessibilityValue = @"Password";
        return;
    }
    
    self.accessibilityValue = nil;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    if (![font isEqual:[self monoFont]])
    {
        _backupFont = font;
    }
}

- (UIFont *)monoFont
{
    return [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightSemibold];
}

- (UIFont *)currentFont
{
    return (self.text.length) ? [self monoFont] : _backupFont;
}

- (void)drawTextInRect:(CGRect)rect
{
    if (!_secureTextEntryWithoutAutofill)
    {
        [super drawTextInRect:rect];
        return;
    }
    
    self.font = [self currentFont];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = rect.size.height - 5;
    
    NSDictionary *attributes = @{ NSFontAttributeName: self.font, NSParagraphStyleAttributeName: paragraphStyle };

    NSMutableString *dotsMutable = [NSMutableString new];
    NSInteger textLength = self.text.length;
    while (textLength --> 0)
    {
        [dotsMutable appendString:@"•"];
    }
    [dotsMutable drawInRect:rect withAttributes:attributes];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_secureTextEntryWithoutAutofill)
    {
        if (action == @selector(copy:)) return NO;
        if (action == @selector(cut:)) return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
