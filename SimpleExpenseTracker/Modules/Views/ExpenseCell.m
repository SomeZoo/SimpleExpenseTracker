//
//  ExpenseCell.m
//

#import "ExpenseCell.h"
#import "CurrencyFormatter.h"

@interface ExpenseCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@end

@implementation ExpenseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
    
    self.amountLabel = [[UILabel alloc] init];
    self.amountLabel.font = [CurrencyFormatter dinFontWithSize:16];
    self.amountLabel.textColor = [UIColor systemRedColor];
    self.amountLabel.textAlignment = NSTextAlignmentRight;
    self.amountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.amountLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    self.dateLabel.textColor = [UIColor secondaryLabelColor];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.dateLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
        [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.amountLabel.leadingAnchor constant:-8],
        
        [self.amountLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.amountLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        
        [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:4],
        [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10]
    ]];
}

- (void)configureWithExpense:(Expense *)expense {
    self.titleLabel.text = expense.title;
    self.amountLabel.attributedText = [CurrencyFormatter attributedExpenseAmount:expense.amount fontSize:16 color:[UIColor systemRedColor]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd HH:mm";
    self.dateLabel.text = [formatter stringFromDate:expense.date];
}

@end
