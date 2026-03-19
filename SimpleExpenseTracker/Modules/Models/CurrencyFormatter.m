//
//  CurrencyFormatter.m
//  SimpleExpenseTracker
//
//  金额格式化工具类 - DIN字体 + 千位分隔符
//

#import "CurrencyFormatter.h"

@implementation CurrencyFormatter

+ (UIFont *)dinFontWithSize:(CGFloat)size {
    // 优先使用 DIN Alternate Bold
    UIFont *font = [UIFont fontWithName:@"DINAlternate-Bold" size:size];
    if (!font) {
        // 备选 DIN Condensed Bold
        font = [UIFont fontWithName:@"DINCondensed-Bold" size:size];
    }
    if (!font) {
        // 回退到等宽数字系统字体
        font = [UIFont monospacedDigitSystemFontOfSize:size weight:UIFontWeightBold];
    }
    return font;
}

+ (NSString *)formattedAmount:(double)amount {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    formatter.groupingSeparator = @",";
    formatter.groupingSize = 3;
    return [formatter stringFromNumber:@(amount)];
}

+ (NSString *)formattedAmountWithSymbol:(double)amount {
    NSString *formatted = [self formattedAmount:amount];
    return [NSString stringWithFormat:@"¥%@", formatted];
}

+ (NSString *)formattedExpenseAmount:(double)amount {
    NSString *formatted = [self formattedAmount:amount];
    return [NSString stringWithFormat:@"-¥%@", formatted];
}

+ (NSAttributedString *)attributedAmount:(double)amount fontSize:(CGFloat)fontSize color:(UIColor *)color {
    NSString *amountText = [self formattedAmountWithSymbol:amount];
    NSString *symbol = @"¥";
    NSString *numberText = [self formattedAmount:amount];
    
    UIFont *dinFont = [self dinFontWithSize:fontSize];
    UIFont *normalFont = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:amountText];
    
    // 货币符号用普通字体
    [attributedString addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, symbol.length)];
    
    // 数字部分用 DIN 字体
    [attributedString addAttribute:NSFontAttributeName value:dinFont range:NSMakeRange(symbol.length, numberText.length)];
    
    if (color) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, amountText.length)];
    }
    
    return attributedString;
}

+ (NSAttributedString *)attributedExpenseAmount:(double)amount fontSize:(CGFloat)fontSize color:(UIColor *)color {
    NSString *amountText = [self formattedExpenseAmount:amount];
    NSString *prefix = @"-¥";
    NSString *numberText = [self formattedAmount:amount];
    
    UIFont *dinFont = [self dinFontWithSize:fontSize];
    UIFont *normalFont = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:amountText];
    
    // 负号和货币符号用普通字体
    [attributedString addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, prefix.length)];
    
    // 数字部分用 DIN 字体
    [attributedString addAttribute:NSFontAttributeName value:dinFont range:NSMakeRange(prefix.length, numberText.length)];
    
    if (color) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, amountText.length)];
    }
    
    return attributedString;
}

@end