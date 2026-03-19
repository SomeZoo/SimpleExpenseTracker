//
//  CurrencyFormatter.h
//  SimpleExpenseTracker
//
//  金额格式化工具类 - DIN字体 + 千位分隔符
//

#import <UIKit/UIKit.h>

@interface CurrencyFormatter : NSObject

// 获取 DIN 风格的字体
+ (UIFont *)dinFontWithSize:(CGFloat)size;

// 格式化金额字符串（带千位分隔符）
+ (NSString *)formattedAmount:(double)amount;

// 格式化金额字符串（带千位分隔符和货币符号）
+ (NSString *)formattedAmountWithSymbol:(double)amount;

// 格式化支出金额（带负号和货币符号）
+ (NSString *)formattedExpenseAmount:(double)amount;

// 创建带 DIN 字体的 attributed string
+ (NSAttributedString *)attributedAmount:(double)amount fontSize:(CGFloat)fontSize color:(UIColor *)color;

// 创建带负号的支出金额 attributed string（货币符号普通字体，数字 DIN 字体）
+ (NSAttributedString *)attributedExpenseAmount:(double)amount fontSize:(CGFloat)fontSize color:(UIColor *)color;

@end