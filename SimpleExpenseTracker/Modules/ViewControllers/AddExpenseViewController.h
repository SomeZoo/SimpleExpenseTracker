//
//  AddExpenseViewController.h
//

#import <UIKit/UIKit.h>

@class AddExpenseViewController;

@protocol AddExpenseViewControllerDelegate <NSObject>
- (void)addExpenseViewControllerDidSave:(AddExpenseViewController *)controller;
@end

@interface AddExpenseViewController : UIViewController
@property (nonatomic, weak) id<AddExpenseViewControllerDelegate> delegate;
@end
