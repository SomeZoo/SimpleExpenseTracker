//
//  ExpenseSharePreviewView.m
//  SimpleExpenseTracker
//

#import "ExpenseSharePreviewView.h"
#import "Expense.h"
#import "CurrencyFormatter.h"
#import <objc/runtime.h>

static const CGFloat kCardWidth = 340;
static const CGFloat kCardHeight = 460;

@interface ExpenseSharePreviewView ()
@property (nonatomic, strong) Expense *expense;
@property (nonatomic, strong) UIView *shareCardView;
@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *contentContainer;
@end

@implementation ExpenseSharePreviewView

- (instancetype)initWithExpense:(Expense *)expense {
    self = [super init];
    if (self) {
        _expense = expense;
        [self createShareCard];
        [self generateShareImage];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];

    // 毛玻璃背景
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.blurView];

    // 背景点击关闭
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.blurView.contentView addGestureRecognizer:tapGesture];

    // 内容容器
    self.contentContainer = [[UIView alloc] init];
    self.contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentContainer];

    // 图片容器
    UIView *imageContainer = [self createImageContainer];
    [self.contentContainer addSubview:imageContainer];

    // 按钮
    UIButton *saveButton = [self createButtonWithTitle:@"📷 保存到相册" color:[UIColor systemBlueColor] action:@selector(saveButtonTapped:)];
    UIButton *shareButton = [self createButtonWithTitle:@"📤 分享" color:[UIColor systemGreenColor] action:@selector(shareButtonTapped:)];

    [self.contentContainer addSubview:saveButton];
    [self.contentContainer addSubview:shareButton];

    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightLight];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // 毛玻璃背景铺满
        [self.blurView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        // 内容容器居中
        [self.contentContainer.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.contentContainer.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.contentContainer.widthAnchor constraintEqualToConstant:kCardWidth],

        // 图片容器
        [imageContainer.topAnchor constraintEqualToAnchor:self.contentContainer.topAnchor],
        [imageContainer.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor],
        [imageContainer.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor],
        [imageContainer.heightAnchor constraintEqualToConstant:kCardHeight],

        // 保存按钮
        [saveButton.topAnchor constraintEqualToAnchor:imageContainer.bottomAnchor constant:20],
        [saveButton.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor],
        [saveButton.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor],
        [saveButton.heightAnchor constraintEqualToConstant:50],

        // 分享按钮
        [shareButton.topAnchor constraintEqualToAnchor:saveButton.bottomAnchor constant:12],
        [shareButton.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor],
        [shareButton.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor],
        [shareButton.heightAnchor constraintEqualToConstant:50],
        [shareButton.bottomAnchor constraintEqualToAnchor:self.contentContainer.bottomAnchor],

        // 关闭按钮 - 固定在屏幕右上角
        [closeButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:60],
        [closeButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [closeButton.widthAnchor constraintEqualToConstant:44],
        [closeButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (UIView *)createImageContainer {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.cornerRadius = 16;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowOffset = CGSizeMake(0, 10);
    container.layer.shadowRadius = 20;
    container.layer.shadowOpacity = 0.3;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.shareImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = 16;
    imageView.clipsToBounds = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:imageView];

    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:container.topAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:container.bottomAnchor]
    ]];

    return container;
}

- (UIButton *)createButtonWithTitle:(NSString *)title color:(UIColor *)color action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = color;
    button.layer.cornerRadius = 25;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Share Card Generation

- (void)createShareCard {
    CGFloat margin = 24;
    CGFloat currentY = margin;

    self.shareCardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCardWidth, 0)];
    self.shareCardView.backgroundColor = [UIColor systemBackgroundColor];
    self.shareCardView.layer.cornerRadius = 16;

    // 顶部装饰条
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCardWidth, 6)];
    topBar.backgroundColor = [UIColor systemRedColor];
    [self.shareCardView addSubview:topBar];
    currentY += 20;

    // 金额 - 自适应高度确保完整显示
    UILabel *amountLabel = [[UILabel alloc] init];
    amountLabel.attributedText = [CurrencyFormatter attributedExpenseAmount:self.expense.amount fontSize:44 color:[UIColor systemRedColor]];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.numberOfLines = 1;
    amountLabel.adjustsFontSizeToFitWidth = YES;
    amountLabel.minimumScaleFactor = 0.7;
    [amountLabel sizeToFit];
    
    CGRect amountFrame = amountLabel.frame;
    amountFrame.origin.x = margin;
    amountFrame.origin.y = currentY;
    amountFrame.size.width = kCardWidth - margin * 2;
    amountFrame.size.height = MAX(amountFrame.size.height, 55);
    amountLabel.frame = amountFrame;
    
    [self.shareCardView addSubview:amountLabel];
    currentY += amountFrame.size.height + 20;

    // 分隔线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(margin, currentY, kCardWidth - margin * 2, 1)];
    separator.backgroundColor = [UIColor separatorColor];
    [self.shareCardView addSubview:separator];
    currentY += 20;

    // 信息行
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    NSString *dateString = [formatter stringFromDate:self.expense.date];

    currentY = [self addInfoRowWithTitle:@"标题" value:self.expense.title y:currentY];
    currentY = [self addInfoRowWithTitle:@"分类" value:self.expense.category ?: @"-" y:currentY];
    currentY = [self addInfoRowWithTitle:@"时间" value:dateString y:currentY];

    if (self.expense.note && self.expense.note.length > 0) {
        currentY = [self addInfoRowWithTitle:@"备注" value:self.expense.note y:currentY];
    }

    currentY += 16;

    // 底部品牌
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, currentY, kCardWidth, 50)];
    bottomBar.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];

    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, kCardWidth, 20)];
    brandLabel.text = @"来自 简单记账";
    brandLabel.font = [UIFont systemFontOfSize:13];
    brandLabel.textColor = [UIColor tertiaryLabelColor];
    brandLabel.textAlignment = NSTextAlignmentCenter;
    [bottomBar addSubview:brandLabel];

    [self.shareCardView addSubview:bottomBar];
    currentY += 50;

    CGRect frame = self.shareCardView.frame;
    frame.size.height = currentY;
    self.shareCardView.frame = frame;
}

- (CGFloat)addInfoRowWithTitle:(NSString *)title value:(NSString *)value y:(CGFloat)y {
    CGFloat margin = 24;
    CGFloat rowHeight = 22;
    CGFloat spacing = 12;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, 70, rowHeight)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor secondaryLabelColor];
    [self.shareCardView addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin + 80, y, kCardWidth - margin * 2 - 80, rowHeight)];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    valueLabel.textColor = [UIColor labelColor];
    valueLabel.numberOfLines = 0;

    CGSize maxSize = CGSizeMake(valueLabel.bounds.size.width, CGFLOAT_MAX);
    CGSize textSize = [value boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: valueLabel.font}
                                          context:nil].size;
    CGFloat valueHeight = MAX(rowHeight, ceil(textSize.height));
    valueLabel.frame = CGRectMake(margin + 80, y, valueLabel.bounds.size.width, valueHeight);

    [self.shareCardView addSubview:valueLabel];

    return y + valueHeight + spacing;
}

- (void)generateShareImage {
    if (!self.shareCardView || CGSizeEqualToSize(self.shareCardView.bounds.size, CGSizeZero)) {
        NSLog(@"Share card view is nil or has zero size");
        return;
    }

    UIGraphicsBeginImageContextWithOptions(self.shareCardView.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.shareCardView.layer renderInContext:context];
    self.shareImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark - Show / Dismiss

- (void)showInView:(UIView *)parentView {
    // 获取窗口并添加到窗口上，确保真正全屏
    UIWindow *window = parentView.window ?: [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    
    if (window) {
        self.frame = window.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.alpha = 0;
        [window addSubview:self];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Actions

- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.contentContainer];
    if (!CGRectContainsPoint(self.contentContainer.bounds, location)) {
        [self dismiss];
        if ([self.delegate respondsToSelector:@selector(sharePreviewViewDidTapClose)]) {
            [self.delegate sharePreviewViewDidTapClose];
        }
    }
}

- (void)closeButtonTapped:(UIButton *)sender {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(sharePreviewViewDidTapClose)]) {
        [self.delegate sharePreviewViewDidTapClose];
    }
}

- (void)saveButtonTapped:(UIButton *)sender {
    if (self.shareImage && [self.delegate respondsToSelector:@selector(sharePreviewViewDidTapSave:)]) {
        [self.delegate sharePreviewViewDidTapSave:self.shareImage];
    }
}

- (void)shareButtonTapped:(UIButton *)sender {
    if (self.shareImage && [self.delegate respondsToSelector:@selector(sharePreviewViewDidTapShare:)]) {
        [self.delegate sharePreviewViewDidTapShare:self.shareImage];
    }
}

@end
