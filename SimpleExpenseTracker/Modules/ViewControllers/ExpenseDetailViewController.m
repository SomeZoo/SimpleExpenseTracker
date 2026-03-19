//
//  ExpenseDetailViewController.m
//  SimpleExpenseTracker
//

#import "ExpenseDetailViewController.h"
#import "Expense.h"
#import "CurrencyFormatter.h"

@interface ExpenseDetailViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation ExpenseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账单详情";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    [self setupUI];
    [self loadData];
}

- (void)setupUI {
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    // ContentView
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
}

- (void)loadData {
    if (!self.expense) return;
    
    CGFloat margin = 16;
    CGFloat cardMargin = 20;
    CGFloat currentY = cardMargin;
    
    // 金额卡片
    UIView *amountCard = [self createCardWithFrame:CGRectMake(margin, currentY, self.view.bounds.size.width - margin * 2, 120)];
    
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, amountCard.bounds.size.width, 50)];
    amountLabel.attributedText = [CurrencyFormatter attributedExpenseAmount:self.expense.amount fontSize:42 color:[UIColor systemRedColor]];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    [amountCard addSubview:amountLabel];
    
    [self.contentView addSubview:amountCard];
    currentY += 120 + cardMargin;
    
    // 信息卡片
    UIView *infoCard = [self createCardWithFrame:CGRectMake(margin, currentY, self.view.bounds.size.width - margin * 2, 0)];
    CGFloat infoY = 16;
    
    // 标题
    infoY = [self addInfoRowToView:infoCard title:@"标题" value:self.expense.title y:infoY];
    
    // 分类
    infoY = [self addInfoRowToView:infoCard title:@"分类" value:self.expense.category ?: @"-" y:infoY];
    
    // 日期时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    NSString *dateString = [formatter stringFromDate:self.expense.date];
    infoY = [self addInfoRowToView:infoCard title:@"时间" value:dateString y:infoY];
    
    // 备注（如果有）
    if (self.expense.note && self.expense.note.length > 0) {
        infoY = [self addInfoRowToView:infoCard title:@"备注" value:self.expense.note y:infoY];
    }
    
    // 调整信息卡片高度
    CGRect infoFrame = infoCard.frame;
    infoFrame.size.height = infoY + 16;
    infoCard.frame = infoFrame;
    
    [self.contentView addSubview:infoCard];
    currentY += infoFrame.size.height + cardMargin;
    
    // 设置 contentView 高度
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = currentY;
    self.contentView.frame = contentFrame;
}

- (UIView *)createCardWithFrame:(CGRect)frame {
    UIView *card = [[UIView alloc] initWithFrame:frame];
    card.backgroundColor = [UIColor systemBackgroundColor];
    card.layer.cornerRadius = 12;
    return card;
}

- (CGFloat)addInfoRowToView:(UIView *)view title:(NSString *)title value:(NSString *)value y:(CGFloat)y {
    CGFloat margin = 16;
    CGFloat rowHeight = 24;
    CGFloat spacing = 8;
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, 60, rowHeight)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor secondaryLabelColor];
    [view addSubview:titleLabel];
    
    // 值
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin + 70, y, view.bounds.size.width - margin * 2 - 70, rowHeight)];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:16];
    valueLabel.textColor = [UIColor labelColor];
    valueLabel.numberOfLines = 0;
    
    // 计算高度
    CGSize maxSize = CGSizeMake(valueLabel.bounds.size.width, CGFLOAT_MAX);
    CGSize textSize = [value boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: valueLabel.font}
                                          context:nil].size;
    CGFloat valueHeight = MAX(rowHeight, ceil(textSize.height));
    valueLabel.frame = CGRectMake(margin + 70, y, valueLabel.bounds.size.width, valueHeight);
    
    [view addSubview:valueLabel];
    
    return y + valueHeight + spacing;
}

@end