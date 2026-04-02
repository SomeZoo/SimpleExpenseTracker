//
//  ExpenseDetailViewController.m
//  SimpleExpenseTracker
//

#import "ExpenseDetailViewController.h"
#import "Expense.h"
#import "CurrencyFormatter.h"
#import "ExpenseSharePreviewView.h"
#import <Photos/Photos.h>

@interface ExpenseDetailViewController () <ExpenseSharePreviewViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ExpenseSharePreviewView *previewView;
@end

@implementation ExpenseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账单详情";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    [self setupUI];
    [self loadData];
    [self setupShareButton];
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

#pragma mark - Share Functionality

- (void)setupShareButton {
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(shareButtonTapped)];
    self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)shareButtonTapped {
    self.previewView = [[ExpenseSharePreviewView alloc] initWithExpense:self.expense];
    self.previewView.delegate = self;
    [self.previewView showInView:self.view];
}

#pragma mark - ExpenseSharePreviewViewDelegate

- (void)sharePreviewViewDidTapSave:(UIImage *)image {
    [self saveImageToAlbumWithImage:image];
}

- (void)sharePreviewViewDidTapShare:(UIImage *)image {
    [self shareImage:image];
}

- (void)sharePreviewViewDidTapClose {
    self.previewView = nil;
}

#pragma mark - Save & Share

- (void)saveImageToAlbumWithImage:(UIImage *)image {
    if (!image) {
        [self showAlertWithTitle:@"生成失败" message:@"无法生成分享图片"];
        return;
    }

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    void (^saveBlock)(void) = ^{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            request.creationDate = [NSDate date];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self showAlertWithTitle:@"保存成功" message:@"账单图片已保存到相册"];
                } else {
                    [self showAlertWithTitle:@"保存失败" message:error.localizedDescription ?: @"未知错误"];
                }
            });
        }];
    };

    if (status == PHAuthorizationStatusAuthorized) {
        saveBlock();
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (newStatus == PHAuthorizationStatusAuthorized) {
                    saveBlock();
                } else {
                    [self showAlertWithTitle:@"无法保存" message:@"请在设置中允许访问相册权限"];
                }
            });
        }];
    } else {
        [self showAlertWithTitle:@"无法保存" message:@"请在设置中允许访问相册权限"];
    }
}

- (void)shareImage:(UIImage *)image {
    if (!image) {
        [self showAlertWithTitle:@"生成失败" message:@"无法生成分享图片"];
        return;
    }

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                                                             applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
