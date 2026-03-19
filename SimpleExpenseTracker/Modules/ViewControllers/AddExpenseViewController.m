//
//  AddExpenseViewController.m
//

#import "AddExpenseViewController.h"
#import "ExpenseManager.h"
#import "CurrencyFormatter.h"

@interface AddExpenseViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextField *amountField;
@property (nonatomic, strong) UITextField *categoryField;
@property (nonatomic, strong) UITextView *noteTextView;
@property (nonatomic, strong) UILabel *noteCountLabel;
@property (nonatomic, strong) UILabel *notePlaceholderLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSArray<NSString *> *categories;
@property (nonatomic, strong) UIPickerView *picker;
@end

@implementation AddExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.expenseToEdit ? @"编辑记账" : @"记一笔";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.categories = @[@"餐饮", @"交通", @"购物", @"娱乐", @"居住", @"医疗", @"教育", @"其他"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    [self setupUI];
    [self loadExpenseDataIfEditing];
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
    // 使用 CurrencyFormatter 的 DIN 字体
    UIFont *dinFont = [CurrencyFormatter dinFontWithSize:48];
    self.amountField.font = dinFont;
    self.amountField.textColor = [UIColor whiteColor];
    self.amountField.keyboardType = UIKeyboardTypeDecimalPad;
    self.amountField.placeholder = @"0.00";
    self.amountField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.5], NSFontAttributeName: dinFont}];
    self.amountField.translatesAutoresizingMaskIntoConstraints = NO;
    self.amountField.delegate = self;
    self.amountField.textAlignment = NSTextAlignmentCenter;
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
    
    // Note
    UIView *noteContainer = [[UIView alloc] init];
    noteContainer.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    noteContainer.layer.cornerRadius = 8;
    noteContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:noteContainer];
    
    self.noteTextView = [[UITextView alloc] init];
    self.noteTextView.font = [UIFont systemFontOfSize:16];
    self.noteTextView.backgroundColor = [UIColor clearColor];
    self.noteTextView.textContainerInset = UIEdgeInsetsMake(8, 4, 8, 4);
    self.noteTextView.textContainer.lineFragmentPadding = 0;
    self.noteTextView.delegate = self;
    self.noteTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.noteTextView.scrollEnabled = NO;
    [noteContainer addSubview:self.noteTextView];
    
    self.notePlaceholderLabel = [[UILabel alloc] init];
    self.notePlaceholderLabel.text = @"备注（最多50字）";
    self.notePlaceholderLabel.font = [UIFont systemFontOfSize:16];
    self.notePlaceholderLabel.textColor = [UIColor placeholderTextColor];
    self.notePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [noteContainer addSubview:self.notePlaceholderLabel];
    
    self.noteCountLabel = [[UILabel alloc] init];
    self.noteCountLabel.font = [UIFont systemFontOfSize:12];
    self.noteCountLabel.textColor = [UIColor secondaryLabelColor];
    self.noteCountLabel.text = @"0/50";
    self.noteCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [noteContainer addSubview:self.noteCountLabel];
    
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
        
        [noteContainer.topAnchor constraintEqualToAnchor:self.categoryField.bottomAnchor constant:12],
        [noteContainer.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16],
        [noteContainer.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16],
        
        [self.noteTextView.topAnchor constraintEqualToAnchor:noteContainer.topAnchor constant:4],
        [self.noteTextView.leadingAnchor constraintEqualToAnchor:noteContainer.leadingAnchor constant:12],
        [self.noteTextView.trailingAnchor constraintEqualToAnchor:noteContainer.trailingAnchor constant:-12],
        
        [self.notePlaceholderLabel.topAnchor constraintEqualToAnchor:self.noteTextView.topAnchor constant:8],
        [self.notePlaceholderLabel.leadingAnchor constraintEqualToAnchor:self.noteTextView.leadingAnchor constant:4],
        
        [self.noteCountLabel.topAnchor constraintEqualToAnchor:self.noteTextView.bottomAnchor constant:4],
        [self.noteCountLabel.trailingAnchor constraintEqualToAnchor:noteContainer.trailingAnchor constant:-12],
        [self.noteCountLabel.bottomAnchor constraintEqualToAnchor:noteContainer.bottomAnchor constant:-8],
        
        [self.datePicker.topAnchor constraintEqualToAnchor:noteContainer.bottomAnchor constant:20],
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    NSString *title = self.titleField.text ?: @"";
    // 去掉千位分隔符后解析金额
    NSString *amountText = [self.amountField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    double amount = [amountText doubleValue];
    
    if (title.length == 0 || amount <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入标题和金额" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *note = self.noteTextView.text.length > 0 ? self.noteTextView.text : nil;
    
    if (self.expenseToEdit) {
        // 编辑模式：更新现有记账
        self.expenseToEdit.title = title;
        self.expenseToEdit.amount = amount;
        self.expenseToEdit.date = self.datePicker.date;
        self.expenseToEdit.category = self.categoryField.text;
        self.expenseToEdit.note = note;
        [[ExpenseManager sharedManager] updateExpense:self.expenseToEdit];
    } else {
        // 新增模式：创建新记账
        Expense *expense = [[Expense alloc] initWithTitle:title amount:amount date:self.datePicker.date category:self.categoryField.text note:note];
        [[ExpenseManager sharedManager] addExpense:expense];
    }
    
    if ([self.delegate respondsToSelector:@selector(addExpenseViewControllerDidSave:)]) {
        [self.delegate addExpenseViewControllerDidSave:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Load Data

- (void)loadExpenseDataIfEditing {
    if (!self.expenseToEdit) return;
    
    // 加载金额
    NSString *amountText = [CurrencyFormatter formattedAmount:self.expenseToEdit.amount];
    self.amountField.text = amountText;
    
    // 加载标题
    self.titleField.text = self.expenseToEdit.title;
    
    // 加载分类
    self.categoryField.text = self.expenseToEdit.category ?: self.categories[0];
    NSInteger categoryIndex = [self.categories indexOfObject:self.categoryField.text];
    if (categoryIndex != NSNotFound) {
        [self.picker selectRow:categoryIndex inComponent:0 animated:NO];
    }
    
    // 加载日期
    self.datePicker.date = self.expenseToEdit.date;
    
    // 加载备注
    if (self.expenseToEdit.note) {
        self.noteTextView.text = self.expenseToEdit.note;
        self.notePlaceholderLabel.hidden = YES;
        self.noteCountLabel.text = [NSString stringWithFormat:@"%lu/50", (unsigned long)self.expenseToEdit.note.length];
    }
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.categories.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.categories[row]; }
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component { self.categoryField.text = self.categories[row]; }

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.noteTextView) {
        self.notePlaceholderLabel.hidden = textView.text.length > 0;
        self.noteCountLabel.text = [NSString stringWithFormat:@"%lu/50", (unsigned long)textView.text.length];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.noteTextView) {
        NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if (newText.length > 50) {
            return NO;
        }
    }
    return YES;
}

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
    
    // 获取原始文本和光标位置（基于原始带逗号的文本）
    NSString *originalText = textField.text;
    
    // 计算去掉逗号后的光标位置
    NSString *textBeforeCursor = [originalText substringToIndex:range.location];
    NSInteger commasBeforeCursor = [[textBeforeCursor componentsSeparatedByString:@","] count] - 1;
    NSInteger cleanCursorPosition = range.location - commasBeforeCursor;
    
    // 获取去掉逗号后的纯数字文本
    NSString *currentText = [originalText stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    // 在纯数字文本中插入新字符
    NSString *newText = [currentText stringByReplacingCharactersInRange:NSMakeRange(cleanCursorPosition, range.length) withString:string];
    
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
    if (newText.length > 12) {
        return NO;
    }
    
    // 格式化显示（添加千位分隔符）
    NSString *formattedText = [self formatAmountString:newText];
    textField.text = formattedText;
    
    // 计算新的光标位置
    NSInteger newCleanCursorPosition = cleanCursorPosition + string.length;
    NSInteger newCursorPosition = [self cursorPositionInFormattedText:formattedText forCleanPosition:newCleanCursorPosition];
    
    UITextPosition *newPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorPosition];
    textField.selectedTextRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
    
    return NO; // 我们已经手动设置了 text，所以返回 NO
}

// 根据纯数字文本中的位置，计算格式化后文本中的光标位置
- (NSInteger)cursorPositionInFormattedText:(NSString *)formattedText forCleanPosition:(NSInteger)cleanPosition {
    NSInteger result = 0;
    NSInteger digitCount = 0;
    
    for (NSInteger i = 0; i < formattedText.length; i++) {
        unichar c = [formattedText characterAtIndex:i];
        if (c != ',') {
            if (digitCount == cleanPosition) {
                return i;
            }
            digitCount++;
        }
    }
    
    return formattedText.length;
}

- (NSString *)formatAmountString:(NSString *)amountString {
    if (amountString.length == 0 || [amountString isEqualToString:@"."]) {
        return amountString;
    }
    
    // 分离整数部分和小数部分
    NSArray *parts = [amountString componentsSeparatedByString:@"."];
    NSString *integerPart = parts[0];
    NSString *decimalPart = parts.count > 1 ? [NSString stringWithFormat:@".%@", parts[1]] : @"";
    
    // 去掉整数部分前面的0（除非是0本身）
    integerPart = [integerPart stringByReplacingOccurrencesOfString:@"," withString:@""];
    if (integerPart.length > 1 && [integerPart hasPrefix:@"0"]) {
        integerPart = [integerPart substringFromIndex:1];
    }
    
    // 添加千位分隔符
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.groupingSeparator = @",";
    formatter.groupingSize = 3;
    
    NSNumber *number = @([integerPart doubleValue]);
    NSString *formattedInteger = [formatter stringFromNumber:number];
    
    if (!formattedInteger) {
        formattedInteger = integerPart;
    }
    
    return [NSString stringWithFormat:@"%@%@", formattedInteger, decimalPart];
}

@end
