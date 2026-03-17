//
//  Expense.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Expense : NSObject

@property (nonatomic, strong) NSString *expenseId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) double amount;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong, nullable) NSString *category;
@property (nonatomic, strong, nullable) NSString *note;

- (instancetype)initWithTitle:(NSString *)title amount:(double)amount date:(NSDate *)date category:(nullable NSString *)category note:(nullable NSString *)note;
- (NSDictionary *)toDictionary;
+ (instancetype)fromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
