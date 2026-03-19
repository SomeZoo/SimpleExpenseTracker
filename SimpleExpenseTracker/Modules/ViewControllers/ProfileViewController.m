//
//  ProfileViewController.m
//  SimpleExpenseTracker
//

#import "ProfileViewController.h"
#import "ExpenseManager.h"
#import "CurrencyFormatter.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *signatureLabel;
@property (nonatomic, strong) UILabel *monthValueLabel;
@property (nonatomic, strong) UILabel *daysValueLabel;
@property (nonatomic, strong) UILabel *countValueLabel;
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    self.menuItems = @[
        @{@"title": @"账单统计", @"icon": @"📊", @"action": @"showStatistics"},
        @{@"title": @"分类管理", @"icon": @"🏷️", @"action": @"manageCategories"},
        @{@"title": @"数据导出", @"icon": @"📤", @"action": @"exportData"},
        @{@"title": @"设置", @"icon": @"⚙️", @"action": @"showSettings"}
    ];
    
    [self setupUI];
}

- (void)setupUI {
    // 创建表格
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MenuCell"];
    [self.view addSubview:self.tableView];
    
    // 表格约束
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];;
    
    // 设置 HeaderView
    self.tableView.tableHeaderView = [self createHeaderView];
}

- (UIView *)createHeaderView {
    CGFloat screenWidth = self.view.bounds.size.width ?: [[UIScreen mainScreen] bounds].size.width;
    CGFloat margin = 16;
    CGFloat cardWidth = screenWidth - margin * 2;
    
    // Header 容器
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 320)];
    header.backgroundColor = [UIColor clearColor];
    
    // 信息卡片
    UIView *infoCard = [[UIView alloc] initWithFrame:CGRectMake(margin, 16, cardWidth, 180)];
    infoCard.backgroundColor = [UIColor systemBackgroundColor];
    infoCard.layer.cornerRadius = 12;
    
    // 头像
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake((cardWidth - 80) / 2, 20, 80, 80)];
    self.avatarImageView.backgroundColor = [UIColor systemBlueColor];
    self.avatarImageView.layer.cornerRadius = 40;
    self.avatarImageView.clipsToBounds = YES;
    
    UILabel *avatarIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    avatarIcon.text = @"👤";
    avatarIcon.font = [UIFont systemFontOfSize:40];
    avatarIcon.textAlignment = NSTextAlignmentCenter;
    [self.avatarImageView addSubview:avatarIcon];
    
    // 姓名
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, cardWidth, 24)];
    self.nameLabel.text = @"记账达人";
    self.nameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
    // 签名
    self.signatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 138, cardWidth, 20)];
    self.signatureLabel.text = @"记录每一笔，理财更轻松 ✨";
    self.signatureLabel.font = [UIFont systemFontOfSize:14];
    self.signatureLabel.textColor = [UIColor secondaryLabelColor];
    self.signatureLabel.textAlignment = NSTextAlignmentCenter;
    
    [infoCard addSubview:self.avatarImageView];
    [infoCard addSubview:self.nameLabel];
    [infoCard addSubview:self.signatureLabel];
    [header addSubview:infoCard];
    
    // 统计卡片
    UIView *statsCard = [self createStatsCardWithFrame:CGRectMake(margin, 212, cardWidth, 80)];
    [header addSubview:statsCard];
    
    // 绑定初始数据
    [self bindHeaderData];
    
    return header;
}

- (UIView *)createStatsCardWithFrame:(CGRect)frame {
    UIView *card = [[UIView alloc] initWithFrame:frame];
    card.backgroundColor = [UIColor systemBackgroundColor];
    card.layer.cornerRadius = 12;
    
    CGFloat width = frame.size.width;
    
    // 本月支出
    UILabel *monthTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 80, 16)];
    monthTitle.text = @"本月支出";
    monthTitle.font = [UIFont systemFontOfSize:12];
    monthTitle.textColor = [UIColor secondaryLabelColor];
    
    self.monthValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 36, 120, 24)];
    self.monthValueLabel.textColor = [UIColor systemRedColor];
    
    // 记账天数
    UILabel *daysTitle = [[UILabel alloc] initWithFrame:CGRectMake((width - 60) / 2, 16, 60, 16)];
    daysTitle.text = @"记账天数";
    daysTitle.font = [UIFont systemFontOfSize:12];
    daysTitle.textColor = [UIColor secondaryLabelColor];
    daysTitle.textAlignment = NSTextAlignmentCenter;
    
    self.daysValueLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - 60) / 2, 36, 60, 24)];
    self.daysValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.daysValueLabel.textColor = [UIColor systemBlueColor];
    self.daysValueLabel.textAlignment = NSTextAlignmentCenter;
    
    // 总笔数
    UILabel *countTitle = [[UILabel alloc] initWithFrame:CGRectMake(width - 80, 16, 60, 16)];
    countTitle.text = @"总笔数";
    countTitle.font = [UIFont systemFontOfSize:12];
    countTitle.textColor = [UIColor secondaryLabelColor];
    countTitle.textAlignment = NSTextAlignmentRight;
    
    self.countValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - 100, 36, 80, 24)];
    self.countValueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.countValueLabel.textColor = [UIColor systemGreenColor];
    self.countValueLabel.textAlignment = NSTextAlignmentRight;
    
    [card addSubview:monthTitle];
    [card addSubview:self.monthValueLabel];
    [card addSubview:daysTitle];
    [card addSubview:self.daysValueLabel];
    [card addSubview:countTitle];
    [card addSubview:self.countValueLabel];
    
    return card;
}

- (void)bindHeaderData {
    ExpenseManager *manager = [ExpenseManager sharedManager];
    
    self.monthValueLabel.attributedText = [CurrencyFormatter attributedAmount:[manager totalAmountForThisMonth] fontSize:18 color:[UIColor systemRedColor]];
    self.daysValueLabel.text = @"12"; // TODO: 计算实际记账天数
    self.countValueLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[manager allExpenses].count];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateHeaderStats];
}

- (void)updateHeaderStats {
    // 只更新数据，不重新创建 headerView
    [self bindHeaderData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    NSDictionary *item = self.menuItems[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", item[@"icon"], item[@"title"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *action = self.menuItems[indexPath.row][@"action"];
    SEL selector = NSSelectorFromString(action);
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:nil afterDelay:0];
    }
}

#pragma mark - Actions

- (void)showStatistics {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"账单统计"
                                                                   message:@"统计功能即将上线，敬请期待！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)manageCategories {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"分类管理"
                                                                   message:@"分类管理功能即将上线！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)exportData {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"数据导出"
                                                                   message:@"导出功能即将上线！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置"
                                                                   message:@"设置功能即将上线！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end