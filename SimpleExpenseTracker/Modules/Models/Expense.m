//
//  Expense.m
//

#import "Expense.h"

@implementation Expense

- (instancetype)initWithTitle:(NSString *)title amount:(double)amount date:(NSDate *)date category:(nullable NSString *)category note:(nullable NSString *)note {
    self = [super init];
    if (self) {
        _expenseId = [[NSUUID UUID] UUIDString];
        _title = title;
        _amount = amount;
        _date = date;
        _category = category;
        _note = note;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"expenseId"] = self.expenseId;
    dict[@"title"] = self.title;
    dict[@"amount"] = @(self.amount);
    dict[@"date"] = @([self.date timeIntervalSince1970]);
    if (self.category) dict[@"category"] = self.category;
    if (self.note) dict[@"note"] = self.note;
    return [dict copy];
}

+ (instancetype)fromDictionary:(NSDictionary *)dict {
    NSString *title = dict[@"title"];
    double amount = [dict[@"amount"] doubleValue];
    NSTimeInterval timestamp = [dict[@"date"] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *category = dict[@"category"];
    NSString *note = dict[@"note"];
    
    Expense *expense = [[Expense alloc] initWithTitle:title amount:amount date:date category:category note:note];
    expense.expenseId = dict[@"expenseId"] ?: expense.expenseId;
    return expense;
}

@end
