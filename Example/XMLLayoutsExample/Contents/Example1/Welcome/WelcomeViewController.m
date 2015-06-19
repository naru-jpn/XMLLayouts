
#import "WelcomeViewController.h"
#import "OutlineViewController.h"

@implementation WelcomeViewController

#pragma mark - action

- (void)onCloseButtonClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onWelcomeLabelTapped:(id)sender {
    [self.navigationController pushViewController:[OutlineViewController new] animated:YES];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"_welcome", nil)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // add close button
    NSString *title = NSLocalizedString(@"close", nil);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(onCloseButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:item];
    
    // load welcome xml layout
    [self.view loadXMLLayoutsWithResourceName:@"Welcome" completion:^(NSError *error) {
        [self.view findViewByID:R.id(@"@id/welcome") work:^(UIView *view) {
            [view setUserInteractionEnabled:YES];
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onWelcomeLabelTapped:)];
            [view addGestureRecognizer:recognizer];
        }];
    }];
}

- (void)viewDidLayoutSubviews {
    [self.view refreshAllLayout];
}

@end
