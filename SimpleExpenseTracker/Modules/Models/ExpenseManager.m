//
//  ExpenseManager.m
//

#import "ExpenseManager.h"

static NSString * const kExpensesKey = @"saved_expenses";

@interface ExpenseManager ()
@property (nonatomic, strong) NSMutableArray<Expense *> *expenses;
@property (nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation ExpenseManager

+ (instancetype)sharedManager {
    static ExpenseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
        _expenses = [NSMutableArray array];
        [self loadExpenses];
    }
    return self;
}

- (void)loadExpenses {
    NSArray *savedData = [self.defaults objectForKey:kExpensesKey];
    if (savedData) {
        for (NSDictionary *dict in savedData) {
            Expense *expense = [Expense fromDictionary:dict];
            if (expense) [self.expenses addObject:expense];
        }
    }
    [self sortExpenses];
}

- (void)saveExpenses {
    NSMutableArray *dataArray = [NSMutableArray array];
    for (Expense *expense in self.expenses) {
        [dataArray addObject:[expense toDictionary]];
    }
    [self.defaults setObject:dataArray forKey:kExpensesKey];
}

- (void)sortExpenses {
    [self.expenses sortUsingComparator:^NSComparisonResult(Expense *obj1, Expense *obj2) {
        return [obj2.date compare:obj1.date];
    }];
}

- (void)addExpense:(Expense *)expense {
    if (!expense) return;
    [self.expenses insertObject:expense atIndex:0];
    [self saveExpenses];
}

- (void)deleteExpense:(Expense *)expense {
    if (!expense) return;
    NSUInteger index = [self.expenses indexOfObjectPassingTest:^BOOL(Expense *obj, NSUInteger idx, BOOL *stop) {
        return [obj.expenseId isEqualToString:expense.expenseId];
    }];
    if (index != NSNotFound) {
        [self.expenses removeObjectAtIndex:index];
        [self saveExpenses];
    }
}

- (NSArray<Expense *> *)allExpenses {
    return [self.expenses copy];
}

- (double)totalAmountForToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    double total = 0;
    for (Expense *expense in self.expenses) {
        NSDateComponents *expenseComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:expense.date];
        if (expenseComponents.year == todayComponents.year && expenseComponents.month == todayComponents.month && expenseComponents.day == todayComponents.day) {
            total += expense.amount;
        }
    }
    return total;
}

- (double)totalAmountForThisMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *monthComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    double total = 0;
    for (Expense *expense in self.expenses) {
        NSDateComponents *expenseComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:expense.date];
        if (expenseComponents.year == monthComponents.year && expenseComponents.month == monthComponents.month) {
            total += expense.amount;
        }
    }
    return total;
}

@end
