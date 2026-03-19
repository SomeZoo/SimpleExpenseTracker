//
//  AddExpenseViewController.h
//

#import <UIKit/UIKit.h>

@class AddExpenseViewController;
@class Expense;

@protocol AddExpenseViewControllerDelegate <NSObject>
- (void)addExpenseViewControllerDidSave:(AddExpenseViewController *)controller;
@end

@interface AddExpenseViewController : UIViewController
@property (nonatomic, weak) id<AddExpenseViewControllerDelegate> delegate;
@property (nonatomic, strong) Expense *expenseToEdit; // 如果设置了这个属性，则为编辑模式
@end
