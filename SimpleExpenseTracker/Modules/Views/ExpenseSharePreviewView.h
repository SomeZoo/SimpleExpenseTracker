//
//  ExpenseSharePreviewView.h
//  SimpleExpenseTracker
//

#import <UIKit/UIKit.h>

@class Expense;

@protocol ExpenseSharePreviewViewDelegate <NSObject>
- (void)sharePreviewViewDidTapSave:(UIImage *)image;
- (void)sharePreviewViewDidTapShare:(UIImage *)image;
- (void)sharePreviewViewDidTapClose;
@end

@interface ExpenseSharePreviewView : UIView

@property (nonatomic, weak) id<ExpenseSharePreviewViewDelegate> delegate;

- (instancetype)initWithExpense:(Expense *)expense;
- (void)showInView:(UIView *)parentView;
- (void)dismiss;

@end
