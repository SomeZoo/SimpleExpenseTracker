//
//  AddExpenseViewController.m
//

#import "AddExpenseViewController.h"
#import "ExpenseManager.h"

@interface AddExpenseViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextField *amountField;
@property (nonatomic, strong) UITextField *categoryField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSArray<NSString *> *categories;
@property (nonatomic, strong) UIPickerView *picker;
@end

@implementation AddExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"记一笔";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.categories = @[@"餐饮", @"交通", @"购物", @"娱乐", @"居住", @"医疗", @"教育", @"其他"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    [self setupUI];
}

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];
    
    // Amount
    UIView *amountCard = [[UIView alloc] init];
    amountCard.backgroundColor = [UIColor systemBlueColor];
    amountCard.layer.cornerRadius = 12;
    amountCard.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:amountCard];
    
    self.amountField = [[UITextField alloc] init];
    self.amountField.font = [UIFont systemFontOfSize:40 weight:UIFontWeightBold];
    self.amountField.textColor = [UIColor whiteColor];
    self.amountField.keyboardType = UIKeyboardTypeDecimalPad;
    self.amountField.placeholder = @"0.00";
    self.amountField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.5]}];
    self.amountField.translatesAutoresizingMaskIntoConstraints = NO;
    self.amountField.delegate = self;
    [amountCard addSubview:self.amountField];
    
    // Title
    self.titleField = [[UITextField alloc] init];
    self.titleField.placeholder = @"标题（如：午餐）";
    self.titleField.font = [UIFont systemFontOfSize:16];
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleField.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.titleField];
    
    // Category
    self.categoryField = [[UITextField alloc] init];
    self.categoryField.placeholder = @"分类";
    self.categoryField.font = [UIFont systemFontOfSize:16];
    self.categoryField.borderStyle = UITextBorderStyleRoundedRect;
    self.categoryField.text = self.categories[0];
    self.categoryField.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.categoryField];
    
    self.picker = [[UIPickerView alloc] init];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.categoryField.inputView = self.picker;
    
    // Date
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
    self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.datePicker];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [contentView.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor],
        
        [amountCard.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [amountCard.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16],
        [amountCard.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16],
        [amountCard.heightAnchor constraintEqualToConstant:80],
        
        [self.amountField.centerXAnchor constraintEqualToAnchor:amountCard.centerXAnchor],
        [self.amountField.centerYAnchor constraintEqualToAnchor:amountCard.centerYAnchor],
        
        [self.titleField.topAnchor constraintEqualToAnchor:amountCard.bottomAnchor constant:20],
        [self.titleField.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16],
        [self.titleField.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16],
        [self.titleField.heightAnchor constraintEqualToConstant:44],
        
        [self.categoryField.topAnchor constraintEqualToAnchor:self.titleField.bottomAnchor constant:12],
        [self.categoryField.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16],
        [self.categoryField.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16],
        [self.categoryField.heightAnchor constraintEqualToConstant:44],
        
        [self.datePicker.topAnchor constraintEqualToAnchor:self.categoryField.bottomAnchor constant:20],
        [self.datePicker.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [self.datePicker.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20]
    ]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
    NSString *title = self.titleField.text ?: @"";
    double amount = [self.amountField.text doubleValue];
    
    if (title.length == 0 || amount <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入标题和金额" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    Expense *expense = [[Expense alloc] initWithTitle:title amount:amount date:self.datePicker.date category:self.categoryField.text note:nil];
    [[ExpenseManager sharedManager] addExpense:expense];
    
    if ([self.delegate respondsToSelector:@selector(addExpenseViewControllerDidSave:)]) {
        [self.delegate addExpenseViewControllerDidSave:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.categories.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.categories[row]; }
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component { self.categoryField.text = self.categories[row]; }

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != self.amountField) {
        return YES;
    }
    
    // 只允许输入数字和小数点
    NSCharacterSet *allowedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSCharacterSet *inputCharacters = [NSCharacterSet characterSetWithCharactersInString:string];
    if (![allowedCharacters isSupersetOfSet:inputCharacters]) {
        return NO;
    }
    
    // 获取输入后的完整文本
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // 检查小数点数量
    NSUInteger dotCount = [newText componentsSeparatedByString:@"."].count - 1;
    if (dotCount > 1) {
        return NO;
    }
    
    // 限制小数点后两位
    if ([newText containsString:@"."]) {
        NSArray *parts = [newText componentsSeparatedByString:@"."];
        if (parts.count == 2 && [parts[1] length] > 2) {
            return NO;
        }
    }
    
    // 限制总长度（防止过大数字）
    if (newText.length > 10) {
        return NO;
    }
    
    return YES;
}

@end
