//
//  ExpenseCell.h
//

#import <UIKit/UIKit.h>
#import "Expense.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExpenseCell : UITableViewCell

- (void)configureWithExpense:(Expense *)expense;

@end

NS_ASSUME_NONNULL_END
