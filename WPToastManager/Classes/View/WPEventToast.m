//
//  WPEventToast.m
//  WPToastManager
//
//  Created by weiping.lii on 2021/12/10.
//

#import "WPEventToast.h"

@import Masonry;
@import SDWebImage;

@interface WPEventToast ()

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, assign) BOOL roundedAvatar;

@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, strong) UIStackView *labelStack;
@property (nonatomic, strong) UIImageView *indicator;

@end

@implementation WPEventToast

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor systemBackgroundColor];
    [self addSubview:self.contentStack];
    [self.contentStack addArrangedSubview:self.avatar];
    [self.contentStack addArrangedSubview:self.labelStack];
    [self.labelStack addArrangedSubview:self.titleLabel];
    [self.labelStack addArrangedSubview:self.subtitleLabel];
    [self.contentStack addArrangedSubview:self.indicator];
}

- (void)setupConstraints {
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@64);
    }];
    
    [self.contentStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.trailing.inset(12);
    }];
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.indicator setContentHuggingPriority:UILayoutPriorityDefaultLow+10
                                      forAxis:UILayoutConstraintAxisHorizontal];
    [self.indicator setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+10
                                                    forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)bindViewModel:(id<WPToastMessage>)message {
    [super bindViewModel:message];
    
    [self.avatar sd_setImageWithURL:self.message.imageURL placeholderImage:nil];
    self.titleLabel.text = message.title;
    self.subtitleLabel.text = message.subtitle;
    
    self.indicator.hidden = !(self.message.schemeURL.absoluteString.length || self.message.clickAction != nil);
}

#pragma mark -

- (UIImageView *)avatar {
    if (!_avatar) {
        UIImageView *view = [UIImageView new];
        view.layer.cornerRadius = 4.0;
        view.clipsToBounds = YES;
        view.contentMode = UIViewContentModeScaleAspectFit;
        _avatar = view;
    }
    return _avatar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *view = [UILabel new];
        view.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        _titleLabel = view;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        UILabel *view = [UILabel new];
        view.textColor = UIColor.secondaryLabelColor;
        view.font = [UIFont systemFontOfSize:11];
        _subtitleLabel = view;
    }
    return _subtitleLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.userInteractionEnabled = NO;
        view.titleLabel.font = [UIFont systemFontOfSize:12];
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        view.backgroundColor = [UIColor redColor];
        view.contentEdgeInsets = UIEdgeInsetsMake(2, 8, 2, 8);
        [view setTitle:@"关注" forState:UIControlStateNormal];
        _actionButton = view;
    }
    return _actionButton;
}

- (UIStackView *)contentStack {
    if (!_contentStack) {
        UIStackView *view = [UIStackView new];
        view.spacing = 8;
        view.alignment = UIStackViewAlignmentCenter;
        _contentStack = view;
    }
    return _contentStack;
}

- (UIStackView *)labelStack {
    if (!_labelStack) {
        UIStackView *view = [UIStackView new];
        view.spacing = 1;
        view.alignment = UIStackViewAlignmentLeading;
        view.axis = UILayoutConstraintAxisVertical;
        _labelStack = view;
    }
    return _labelStack;
}

- (UIImageView *)indicator {
    if (!_indicator) {
        UIImageView *view = [UIImageView new];
        UIImage *icon = [UIImage wp_bundledImage:@"arrow_r"];
        view.image = icon;
        _indicator = view;
    }
    return _indicator;
}

@end
