//
//  ExpenseManager.h
//

#import <Foundation/Foundation.h>
#import "Expense.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExpenseManager : NSObject

+ (instancetype)sharedManager;

- (void)addExpense:(Expense *)expense;
- (void)deleteExpense:(Expense *)expense;
- (NSArray<Expense *> *)allExpenses;
- (double)totalAmountForToday;
- (double)totalAmountForThisMonth;

@end

NS_ASSUME_NONNULL_END
