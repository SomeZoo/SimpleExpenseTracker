//
//  HomeViewController.m
//

#import "HomeViewController.h"
#import "ExpenseManager.h"
#import "ExpenseCell.h"
#import "AddExpenseViewController.h"
#import "CurrencyFormatter.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, AddExpenseViewControllerDelegate>
@property (nonatomic, strong) UIView *summaryCard;
@property (nonatomic, strong) UILabel *todayAmountLabel;
@property (nonatomic, strong) UILabel *monthAmountLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<Expense *> *recentExpenses;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"记账本";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupUI];
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)setupNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
}

- (void)setupUI {
    // Summary Card
    self.summaryCard = [[UIView alloc] init];
    self.summaryCard.backgroundColor = [UIColor systemBlueColor];
    self.summaryCard.layer.cornerRadius = 12;
    self.summaryCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.summaryCard];
    
    UILabel *todayLabel = [[UILabel alloc] init];
    todayLabel.text = @"今日支出";
    todayLabel.font = [UIFont systemFontOfSize:14];
    todayLabel.textColor = [UIColor whiteColor];
    todayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.summaryCard addSubview:todayLabel];
    
    self.todayAmountLabel = [[UILabel alloc] init];
    self.todayAmountLabel.textColor = [UIColor whiteColor];
    self.todayAmountLabel.attributedText = [CurrencyFormatter attributedAmount:0 fontSize:32 color:[UIColor whiteColor]];
    self.todayAmountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.summaryCard addSubview:self.todayAmountLabel];
    
    UILabel *monthLabel = [[UILabel alloc] init];
    monthLabel.text = @"本月支出";
    monthLabel.font = [UIFont systemFontOfSize:12];
    monthLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    monthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.summaryCard addSubview:monthLabel];
    
    self.monthAmountLabel = [[UILabel alloc] init];
    self.monthAmountLabel.textColor = [UIColor whiteColor];
    self.monthAmountLabel.attributedText = [CurrencyFormatter attributedAmount:0 fontSize:16 color:[UIColor whiteColor]];
    self.monthAmountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.summaryCard addSubview:self.monthAmountLabel];
    
    // Table View
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[ExpenseCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.summaryCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [self.summaryCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.summaryCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.summaryCard.heightAnchor constraintEqualToConstant:100],
        
        [todayLabel.topAnchor constraintEqualToAnchor:self.summaryCard.topAnchor constant:16],
        [todayLabel.leadingAnchor constraintEqualToAnchor:self.summaryCard.leadingAnchor constant:16],
        
        [self.todayAmountLabel.topAnchor constraintEqualToAnchor:todayLabel.bottomAnchor constant:4],
        [self.todayAmountLabel.leadingAnchor constraintEqualToAnchor:self.summaryCard.leadingAnchor constant:16],
        
        [monthLabel.bottomAnchor constraintEqualToAnchor:self.summaryCard.bottomAnchor constant:-12],
        [monthLabel.leadingAnchor constraintEqualToAnchor:self.summaryCard.leadingAnchor constant:16],
        
        [self.monthAmountLabel.centerYAnchor constraintEqualToAnchor:monthLabel.centerYAnchor],
        [self.monthAmountLabel.leadingAnchor constraintEqualToAnchor:monthLabel.trailingAnchor constant:8],
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.summaryCard.bottomAnchor constant:20],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
}

- (void)refreshData {
    ExpenseManager *manager = [ExpenseManager sharedManager];
    self.todayAmountLabel.attributedText = [CurrencyFormatter attributedAmount:[manager totalAmountForToday] fontSize:32 color:[UIColor whiteColor]];
    self.monthAmountLabel.attributedText = [CurrencyFormatter attributedAmount:[manager totalAmountForThisMonth] fontSize:16 color:[UIColor whiteColor]];
    
    NSArray *all = [manager allExpenses];
    self.recentExpenses = [all subarrayWithRange:NSMakeRange(0, MIN(20, all.count))];
    [self.tableView reloadData];
}

- (void)addTapped {
    AddExpenseViewController *vc = [[AddExpenseViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AddExpenseViewControllerDelegate

- (void)addExpenseViewControllerDidSave:(AddExpenseViewController *)controller {
    [self refreshData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentExpenses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExpenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithExpense:self.recentExpenses[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 进入编辑模式
    AddExpenseViewController *vc = [[AddExpenseViewController alloc] init];
    vc.delegate = self;
    vc.expenseToEdit = self.recentExpenses[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ExpenseManager sharedManager] deleteExpense:self.recentExpenses[indexPath.row]];
        [self refreshData];
    }
}

@end
