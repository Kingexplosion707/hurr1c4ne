#import "ViewController.h"
#import "DeviceInfo.h"
#import "CompatibilityChecker.h"
#import "PatchManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, strong) UILabel *deviceModelLabel;
@property (nonatomic, strong) UILabel *osVersionLabel;
@property (nonatomic, strong) UILabel *buildLabel;
@property (nonatomic, strong) UILabel *compatibilityLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *patchButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

#pragma mark - Colors

- (UIColor *)backgroundColor {
    return [UIColor colorWithRed:0.025 green:0.035 blue:0.065 alpha:1.0];
}

- (UIColor *)cardColor {
    return [UIColor colorWithRed:0.045 green:0.060 blue:0.100 alpha:1.0];
}

- (UIColor *)purpleColor {
    return [UIColor colorWithRed:0.48 green:0.20 blue:1.0 alpha:1.0];
}

- (UIColor *)greenColor {
    return [UIColor colorWithRed:0.22 green:0.96 blue:0.65 alpha:1.0];
}

- (UIColor *)mutedColor {
    return [UIColor colorWithRed:0.59 green:0.65 blue:0.82 alpha:1.0];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [self backgroundColor];
    self.view.tintColor = [self greenColor];

    [self buildInterface];
    [self refreshDeviceInfo];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return NO;
}

#pragma mark - UI Helpers

- (UILabel *)labelWithText:(NSString *)text
                      size:(CGFloat)size
                     color:(UIColor *)color
                    weight:(UIFontWeight)weight {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (UIView *)card {
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [self cardColor];
    view.layer.cornerRadius = 22.0;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor =
        [UIColor colorWithRed:0.15 green:0.20 blue:0.34 alpha:1.0].CGColor;
    view.clipsToBounds = YES;
    return view;
}

- (UIStackView *)verticalStackWithSpacing:(CGFloat)spacing {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentFill;
    stack.distribution = UIStackViewDistributionFill;
    stack.spacing = spacing;
    return stack;
}

- (UIView *)sectionHeading:(NSString *)symbol
                     title:(NSString *)title {
    UIStackView *heading = [[UIStackView alloc] init];
    heading.translatesAutoresizingMaskIntoConstraints = NO;
    heading.axis = UILayoutConstraintAxisHorizontal;
    heading.alignment = UIStackViewAlignmentCenter;
    heading.spacing = 12;

    UILabel *icon = [self labelWithText:symbol
                                   size:23
                                  color:[self greenColor]
                                 weight:UIFontWeightSemibold];

    UILabel *name = [self labelWithText:title.uppercaseString
                                   size:13
                                  color:[self mutedColor]
                                 weight:UIFontWeightBold];

    // UILabel has no letterSpacing property.
    // NSKernAttributeName applies letter spacing correctly.
    NSMutableAttributedString *styledName =
        [[NSMutableAttributedString alloc]
            initWithString:title.uppercaseString];

    [styledName addAttribute:NSKernAttributeName
                       value:@1.2
                       range:NSMakeRange(0, styledName.length)];

    name.attributedText = styledName;

    [heading addArrangedSubview:icon];
    [heading addArrangedSubview:name];

    return heading;
}

- (void)addCard:(UIView *)card
          toView:(UIView *)parent
       topAnchor:(NSLayoutYAxisAnchor *)topAnchor
         spacing:(CGFloat)spacing {
    [parent addSubview:card];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:topAnchor constant:spacing],
        [card.leadingAnchor constraintEqualToAnchor:parent.leadingAnchor],
        [card.trailingAnchor constraintEqualToAnchor:parent.trailingAnchor]
    ]];
}

#pragma mark - Build Interface

- (void)buildInterface {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [self backgroundColor];

    [self.view addSubview:scrollView];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [content.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [content.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor]
    ]];

    UIStackView *mainStack = [self verticalStackWithSpacing:20];
    [content addSubview:mainStack];

    [NSLayoutConstraint activateConstraints:@[
        [mainStack.topAnchor constraintEqualToAnchor:content.topAnchor constant:22],
        [mainStack.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [mainStack.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],
        [mainStack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-24]
    ]];

    [mainStack addArrangedSubview:[self buildHeader]];
    [mainStack addArrangedSubview:[self buildDeviceCard]];
    [mainStack addArrangedSubview:[self buildCompatibilityCard]];
    [mainStack addArrangedSubview:[self buildStatusCard]];
    [mainStack addArrangedSubview:[self buildPatchButton]];
    [mainStack addArrangedSubview:[self buildInformationCards]];
    [mainStack addArrangedSubview:[self buildFooter]];

    UIView *tabBar = [self buildBottomBar];
    [self.view addSubview:tabBar];

    [NSLayoutConstraint activateConstraints:@[
        [tabBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tabBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tabBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [tabBar.heightAnchor constraintEqualToConstant:82],

        [scrollView.bottomAnchor constraintEqualToAnchor:tabBar.topAnchor]
    ]];
}

#pragma mark - Header

- (UIView *)buildHeader {
    UIStackView *header = [[UIStackView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.axis = UILayoutConstraintAxisHorizontal;
    header.alignment = UIStackViewAlignmentCenter;
    header.spacing = 14;

    UIView *logo = [[UIView alloc] init];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    logo.backgroundColor =
        [UIColor colorWithRed:0.20 green:0.09 blue:0.40 alpha:1.0];
    logo.layer.cornerRadius = 19;
    logo.layer.borderWidth = 1;
    logo.layer.borderColor = [self purpleColor].CGColor;

    UILabel *logoSymbol = [self labelWithText:@"↯"
                                         size:35
                                        color:[self greenColor]
                                       weight:UIFontWeightHeavy];
    logoSymbol.textAlignment = NSTextAlignmentCenter;

    [logo addSubview:logoSymbol];

    [NSLayoutConstraint activateConstraints:@[
        [logo.widthAnchor constraintEqualToConstant:62],
        [logo.heightAnchor constraintEqualToConstant:62],
        [logoSymbol.centerXAnchor constraintEqualToAnchor:logo.centerXAnchor],
        [logoSymbol.centerYAnchor constraintEqualToAnchor:logo.centerYAnchor]
    ]];

    UIStackView *branding = [self verticalStackWithSpacing:3];

    UILabel *title = [self labelWithText:@"hurr1c4ne"
                                    size:29
                                   color:UIColor.whiteColor
                                  weight:UIFontWeightHeavy];

    NSMutableAttributedString *styledTitle =
        [[NSMutableAttributedString alloc] initWithString:@"hurr1c4ne"];

    [styledTitle addAttribute:NSForegroundColorAttributeName
                        value:[self greenColor]
                        range:NSMakeRange(4, 1)];

    title.attributedText = styledTitle;
    [branding addArrangedSubview:title];

    NSString *subtitleText = @"iOS / iPadOS RESEARCH";

    UILabel *subtitle = [self labelWithText:subtitleText
                                       size:10
                                      color:[self mutedColor]
                                     weight:UIFontWeightBold];

    NSMutableAttributedString *styledSubtitle =
        [[NSMutableAttributedString alloc] initWithString:subtitleText];

    [styledSubtitle addAttribute:NSKernAttributeName
                           value:@2.0
                           range:NSMakeRange(0, styledSubtitle.length)];

    subtitle.attributedText = styledSubtitle;

    [branding addArrangedSubview:subtitle];

    UIView *spacer = [[UIView alloc] init];

    UIStackView *mode = [self verticalStackWithSpacing:4];
    mode.alignment = UIStackViewAlignmentTrailing;

    UILabel *modeLabel = [self labelWithText:@"● RESEARCH"
                                        size:11
                                       color:[self greenColor]
                                      weight:UIFontWeightBold];

    UILabel *modeSub = [self labelWithText:@"MODE"
                                      size:10
                                     color:[self mutedColor]
                                    weight:UIFontWeightMedium];

    [mode addArrangedSubview:modeLabel];
    [mode addArrangedSubview:modeSub];

    [header addArrangedSubview:logo];
    [header addArrangedSubview:branding];
    [header addArrangedSubview:spacer];
    [header addArrangedSubview:mode];

    return header;
}

#pragma mark - Device Card

- (UIView *)buildDeviceCard {
    UIView *card = [self card];

    UIStackView *stack = [self verticalStackWithSpacing:17];
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:19],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-19]
    ]];

    [stack addArrangedSubview:
        [self sectionHeading:@"▣" title:@"Device information"]];

    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];

    [divider.heightAnchor constraintEqualToConstant:1].active = YES;
    [stack addArrangedSubview:divider];

    UIStackView *details = [[UIStackView alloc] init];
    details.translatesAutoresizingMaskIntoConstraints = NO;
    details.axis = UILayoutConstraintAxisHorizontal;
    details.alignment = UIStackViewAlignmentTop;
    details.distribution = UIStackViewDistributionFillEqually;
    details.spacing = 8;

    UIStackView *modelColumn = [self verticalStackWithSpacing:7];
    UIStackView *osColumn = [self verticalStackWithSpacing:7];
    UIStackView *buildColumn = [self verticalStackWithSpacing:7];

    [modelColumn addArrangedSubview:
        [self labelWithText:@"MODEL"
                       size:10
                      color:[self mutedColor]
                     weight:UIFontWeightBold]];

    self.deviceModelLabel =
        [self labelWithText:@"Detecting…"
                       size:15
                      color:UIColor.whiteColor
                     weight:UIFontWeightBold];

    self.deviceModelLabel.adjustsFontSizeToFitWidth = YES;
    self.deviceModelLabel.minimumScaleFactor = 0.75;
    [modelColumn addArrangedSubview:self.deviceModelLabel];

    [osColumn addArrangedSubview:
        [self labelWithText:@"iOS VERSION"
                       size:10
                      color:[self mutedColor]
                     weight:UIFontWeightBold]];

    self.osVersionLabel =
        [self labelWithText:@"Detecting…"
                       size:15
                      color:UIColor.whiteColor
                     weight:UIFontWeightBold];

    [osColumn addArrangedSubview:self.osVersionLabel];

    [buildColumn addArrangedSubview:
        [self labelWithText:@"BUILD"
                       size:10
                      color:[self mutedColor]
                     weight:UIFontWeightBold]];

    self.buildLabel =
        [self labelWithText:@"Detecting…"
                       size:13
                      color:UIColor.whiteColor
                     weight:UIFontWeightMedium];

    self.buildLabel.adjustsFontSizeToFitWidth = YES;
    self.buildLabel.minimumScaleFactor = 0.7;
    [buildColumn addArrangedSubview:self.buildLabel];

    [details addArrangedSubview:modelColumn];
    [details addArrangedSubview:osColumn];
    [details addArrangedSubview:buildColumn];

    [stack addArrangedSubview:details];

    return card;
}

#pragma mark - Compatibility Card

- (UIView *)buildCompatibilityCard {
    UIView *card = [self card];

    UIStackView *stack = [self verticalStackWithSpacing:14];
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:19],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-19]
    ]];

    [stack addArrangedSubview:
        [self sectionHeading:@"✓" title:@"Compatibility"]];

    UIView *inner = [[UIView alloc] init];
    inner.translatesAutoresizingMaskIntoConstraints = NO;
    inner.backgroundColor =
        [UIColor colorWithRed:0.025 green:0.15 blue:0.12 alpha:1];
    inner.layer.cornerRadius = 15;
    inner.layer.borderWidth = 1;
    inner.layer.borderColor =
        [UIColor colorWithRed:0.10 green:0.65 blue:0.45 alpha:0.8].CGColor;

    [stack addArrangedSubview:inner];

    UILabel *range = [self labelWithText:@"TARGET RANGE  ·  A13 AND NEWER"
                                    size:10
                                   color:[self greenColor]
                                  weight:UIFontWeightBold];

    self.compatibilityLabel =
        [self labelWithText:@"Checking operating system…"
                       size:14
                      color:UIColor.whiteColor
                     weight:UIFontWeightSemibold];

    UILabel *note =
        [self labelWithText:@"OS compatibility does not mean a working jailbreak is available."
                       size:11
                      color:[self mutedColor]
                     weight:UIFontWeightRegular];

    UIStackView *innerStack = [self verticalStackWithSpacing:8];
    [inner addSubview:innerStack];

    [innerStack addArrangedSubview:range];
    [innerStack addArrangedSubview:self.compatibilityLabel];
    [innerStack addArrangedSubview:note];

    [NSLayoutConstraint activateConstraints:@[
        [innerStack.topAnchor constraintEqualToAnchor:inner.topAnchor constant:15],
        [innerStack.leadingAnchor constraintEqualToAnchor:inner.leadingAnchor constant:15],
        [innerStack.trailingAnchor constraintEqualToAnchor:inner.trailingAnchor constant:-15],
        [innerStack.bottomAnchor constraintEqualToAnchor:inner.bottomAnchor constant:-15]
    ]];

    return card;
}

#pragma mark - Status Card

- (UIView *)buildStatusCard {
    UIView *card = [self card];

    UIStackView *stack = [self verticalStackWithSpacing:14];
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:19],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-18],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-19]
    ]];

    [stack addArrangedSubview:
        [self sectionHeading:@"∿" title:@"System status"]];

    UIStackView *statusRow = [[UIStackView alloc] init];
    statusRow.translatesAutoresizingMaskIntoConstraints = NO;
    statusRow.axis = UILayoutConstraintAxisHorizontal;
    statusRow.alignment = UIStackViewAlignmentCenter;
    statusRow.spacing = 13;

    UIView *indicator = [[UIView alloc] init];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    indicator.backgroundColor =
        [UIColor colorWithRed:0.18 green:0.12 blue:0.35 alpha:1];
    indicator.layer.cornerRadius = 22;
    indicator.layer.borderWidth = 2;
    indicator.layer.borderColor = [self purpleColor].CGColor;

    [NSLayoutConstraint activateConstraints:@[
        [indicator.widthAnchor constraintEqualToConstant:44],
        [indicator.heightAnchor constraintEqualToConstant:44]
    ]];

    UILabel *dot = [self labelWithText:@"●"
                                  size:17
                                 color:[self greenColor]
                                weight:UIFontWeightBold];

    dot.textAlignment = NSTextAlignmentCenter;
    [indicator addSubview:dot];

    [NSLayoutConstraint activateConstraints:@[
        [dot.centerXAnchor constraintEqualToAnchor:indicator.centerXAnchor],
        [dot.centerYAnchor constraintEqualToAnchor:indicator.centerYAnchor]
    ]];

    UIStackView *statusText = [self verticalStackWithSpacing:4];

    UILabel *ready = [self labelWithText:@"Research scaffold ready"
                                    size:15
                                   color:UIColor.whiteColor
                                  weight:UIFontWeightBold];

    self.statusLabel =
        [self labelWithText:@"No exploit backend is integrated."
                       size:12
                      color:[self mutedColor]
                     weight:UIFontWeightRegular];

    [statusText addArrangedSubview:ready];
    [statusText addArrangedSubview:self.statusLabel];

    [statusRow addArrangedSubview:indicator];
    [statusRow addArrangedSubview:statusText];

    [stack addArrangedSubview:statusRow];

    return card;
}

#pragma mark - Patch Button

- (UIView *)buildPatchButton {
    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;

    self.patchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.patchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.patchButton.backgroundColor = [self purpleColor];
    self.patchButton.layer.cornerRadius = 19;
    self.patchButton.layer.borderWidth = 1;
    self.patchButton.layer.borderColor =
        [UIColor colorWithRed:0.68 green:0.48 blue:1 alpha:1].CGColor;
    self.patchButton.clipsToBounds = YES;

    [self.patchButton setTitle:@"  ↯   PatchMe   ›"
                      forState:UIControlStateNormal];

    [self.patchButton setTitleColor:UIColor.whiteColor
                           forState:UIControlStateNormal];

    self.patchButton.titleLabel.font =
        [UIFont systemFontOfSize:23 weight:UIFontWeightHeavy];

    self.patchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.patchButton.titleLabel.minimumScaleFactor = 0.75;

    // Use the configuration-independent content layout instead of the
    // deprecated contentEdgeInsets property.
    self.patchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.patchButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    [self.patchButton addTarget:self
                         action:@selector(patchTapped)
               forControlEvents:UIControlEventTouchUpInside];

    [container addSubview:self.patchButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.patchButton.topAnchor constraintEqualToAnchor:container.topAnchor],
        [self.patchButton.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [self.patchButton.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [self.patchButton.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [self.patchButton.heightAnchor constraintGreaterThanOrEqualToConstant:76]
    ]];

    return container;
}

#pragma mark - Information Cards

- (UIView *)buildInformationCards {
    UIStackView *row = [[UIStackView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentFill;
    row.distribution = UIStackViewDistributionFillEqually;
    row.spacing = 12;

    UIView *about = [self card];
    UIView *notice = [self card];

    UIStackView *aboutStack = [self verticalStackWithSpacing:10];
    UIStackView *noticeStack = [self verticalStackWithSpacing:10];

    [about addSubview:aboutStack];
    [notice addSubview:noticeStack];

    for (UIView *card in @[about, notice]) {
        [NSLayoutConstraint activateConstraints:@[
            [card.heightAnchor constraintGreaterThanOrEqualToConstant:160]
        ]];
    }

    [NSLayoutConstraint activateConstraints:@[
        [aboutStack.topAnchor constraintEqualToAnchor:about.topAnchor constant:15],
        [aboutStack.leadingAnchor constraintEqualToAnchor:about.leadingAnchor constant:13],
        [aboutStack.trailingAnchor constraintEqualToAnchor:about.trailingAnchor constant:-13],
        [aboutStack.bottomAnchor constraintLessThanOrEqualToAnchor:about.bottomAnchor constant:-15],

        [noticeStack.topAnchor constraintEqualToAnchor:notice.topAnchor constant:15],
        [noticeStack.leadingAnchor constraintEqualToAnchor:notice.leadingAnchor constant:13],
        [noticeStack.trailingAnchor constraintEqualToAnchor:notice.trailingAnchor constant:-13],
        [noticeStack.bottomAnchor constraintLessThanOrEqualToAnchor:notice.bottomAnchor constant:-15]
    ]];

    [aboutStack addArrangedSubview:
        [self labelWithText:@"ⓘ  ABOUT"
                       size:11
                      color:[self mutedColor]
                     weight:UIFontWeightBold]];

    UILabel *aboutText =
        [self labelWithText:
            @"hurr1c4ne is an iOS research project. A compatible backend is required for any patching functionality."
                       size:12
                      color:UIColor.whiteColor
                     weight:UIFontWeightRegular];

    [aboutStack addArrangedSubview:aboutText];

    [noticeStack addArrangedSubview:
        [self labelWithText:@"⚠  IMPORTANT"
                       size:11
                      color:[self mutedColor]
                     weight:UIFontWeightBold]];

    UILabel *noticeText =
        [self labelWithText:
            @"Research scaffold only.\nNo jailbreak capability is implied.\nUse at your own risk."
                       size:12
                      color:UIColor.whiteColor
                     weight:UIFontWeightRegular];

    [noticeStack addArrangedSubview:noticeText];

    [row addArrangedSubview:about];
    [row addArrangedSubview:notice];

    return row;
}

#pragma mark - Footer

- (UIView *)buildFooter {
    UILabel *footer =
        [self labelWithText:@"hurr1c4ne  •  RESEARCH BUILD  •  v0.1.0"
                       size:10
                      color:[self mutedColor]
                     weight:UIFontWeightMedium];

    footer.textAlignment = NSTextAlignmentCenter;
    return footer;
}

#pragma mark - Bottom Navigation

- (UIView *)buildBottomBar {
    UIView *bar = [[UIView alloc] init];
    bar.translatesAutoresizingMaskIntoConstraints = NO;
    bar.backgroundColor =
        [UIColor colorWithRed:0.025 green:0.035 blue:0.065 alpha:0.98];
    bar.layer.borderWidth = 1;
    bar.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.07].CGColor;

    UIStackView *tabs = [[UIStackView alloc] init];
    tabs.translatesAutoresizingMaskIntoConstraints = NO;
    tabs.axis = UILayoutConstraintAxisHorizontal;
    tabs.alignment = UIStackViewAlignmentCenter;
    tabs.distribution = UIStackViewDistributionFillEqually;

    NSArray<NSString *> *symbols = @[@"⌂", @"⚙", @"≡", @"ⓘ"];
    NSArray<NSString *> *titles = @[@"Home", @"Settings", @"Logs", @"About"];

    for (NSUInteger i = 0; i < titles.count; i++) {
        UIStackView *tab = [self verticalStackWithSpacing:3];
        tab.alignment = UIStackViewAlignmentCenter;

        UIColor *color = (i == 0)
            ? [self greenColor]
            : [self mutedColor];

        UILabel *icon = [self labelWithText:symbols[i]
                                       size:23
                                      color:color
                                     weight:UIFontWeightSemibold];

        UILabel *title = [self labelWithText:titles[i]
                                        size:10
                                       color:color
                                      weight:UIFontWeightMedium];

        [tab addArrangedSubview:icon];
        [tab addArrangedSubview:title];
        [tabs addArrangedSubview:tab];
    }

    [bar addSubview:tabs];

    [NSLayoutConstraint activateConstraints:@[
        [tabs.leadingAnchor constraintEqualToAnchor:bar.leadingAnchor constant:12],
        [tabs.trailingAnchor constraintEqualToAnchor:bar.trailingAnchor constant:-12],
        [tabs.topAnchor constraintEqualToAnchor:bar.topAnchor constant:9],
        [tabs.bottomAnchor constraintEqualToAnchor:bar.bottomAnchor constant:-20]
    ]];

    return bar;
}

#pragma mark - Device Information

- (void)refreshDeviceInfo {
    DeviceInfo *info = [DeviceInfo currentDeviceInfo];

    NSString *model = info.modelIdentifier.length
        ? info.modelIdentifier
        : @"Unknown device";

    NSString *osVersion = info.osVersion.length
        ? info.osVersion
        : @"Unknown";

    NSString *build = info.osBuild.length
        ? info.osBuild
        : @"Unknown";

    self.deviceModelLabel.text = model;
    self.osVersionLabel.text = osVersion;
    self.buildLabel.text = build;

    NSString *summary =
        [CompatibilityChecker summaryForOSVersion:osVersion];

    self.compatibilityLabel.text = summary.length
        ? summary
        : @"Compatibility information unavailable.";
}

#pragma mark - Patch Action

- (void)patchTapped {
    self.patchButton.enabled = NO;
    self.patchButton.alpha = 0.75;

    self.statusLabel.text = @"Evaluating available capabilities…";

    [[PatchManager sharedManager]
        evaluateWithCompletion:^(NSString *message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = message.length
                    ? message
                    : @"No additional capabilities reported.";

                self.patchButton.enabled = YES;
                self.patchButton.alpha = 1.0;
            });
        }];
}

@end
