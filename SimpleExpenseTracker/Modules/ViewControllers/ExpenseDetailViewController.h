//
//  ExpenseDetailViewController.h
//  SimpleExpenseTracker
//

#import <UIKit/UIKit.h>

@class Expense;

@interface ExpenseDetailViewController : UIViewController
@property (nonatomic, strong) Expense *expense;
@end