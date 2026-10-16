#import "ViewController.h"
#import "DeviceInfo.h"
#import "CompatibilityChecker.h"
#import "PatchManager.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *patchButton;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.055 green:0.065 blue:0.09 alpha:1];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentFill;
    stack.spacing = 22;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"hurr1c4ne";
    title.font = [UIFont systemFontOfSize:38 weight:UIFontWeightHeavy];
    title.textColor = UIColor.whiteColor;
    title.textAlignment = NSTextAlignmentCenter;

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"iOS / iPadOS research";
    subtitle.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    subtitle.textColor = [UIColor colorWithWhite:0.72 alpha:1];
    subtitle.textAlignment = NSTextAlignmentCenter;

    self.deviceLabel = [[UILabel alloc] init];
    self.deviceLabel.numberOfLines = 0;
    self.deviceLabel.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    self.deviceLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.deviceLabel.textAlignment = NSTextAlignmentCenter;

    self.patchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.patchButton setTitle:@"PatchMe" forState:UIControlStateNormal];
    self.patchButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [self.patchButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.patchButton.backgroundColor = [UIColor colorWithRed:0.42 green:0.22 blue:0.82 alpha:1];
    self.patchButton.layer.cornerRadius = 15;
    self.patchButton.contentEdgeInsets = UIEdgeInsetsMake(16, 28, 16, 28);
    [self.patchButton addTarget:self action:@selector(patchTapped) forControlEvents:UIControlEventTouchUpInside];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor colorWithWhite:0.78 alpha:1];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"Ready. No exploit backend is integrated.";

    UILabel *notice = [[UILabel alloc] init];
    notice.numberOfLines = 0;
    notice.font = [UIFont systemFontOfSize:12];
    notice.textColor = [UIColor colorWithWhite:0.58 alpha:1];
    notice.textAlignment = NSTextAlignmentCenter;
    notice.text = @"Research scaffold only — no jailbreak capability is implied.";

    for (UIView *view in @[title, subtitle, self.deviceLabel, self.patchButton, self.statusLabel, notice]) {
        [stack addArrangedSubview:view];
    }
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-24],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
        [self.deviceLabel.heightAnchor constraintGreaterThanOrEqualToConstant:70]
    ]];
    [self refreshDeviceInfo];
}

- (void)refreshDeviceInfo {
    DeviceInfo *info = [DeviceInfo currentDeviceInfo];
    self.deviceLabel.text = [NSString stringWithFormat:@"Device: %@\nOS: %@ (build %@)\nCompatibility: %@",
        info.modelIdentifier, info.osVersion, info.osBuild,
        [CompatibilityChecker summaryForOSVersion:info.osVersion]];
}

- (void)patchTapped {
    self.patchButton.enabled = NO;
    self.statusLabel.text = @"Checking available capabilities…";
    [[PatchManager sharedManager] evaluateWithCompletion:^(NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = message;
            self.patchButton.enabled = YES;
        });
    }];
}
@end
