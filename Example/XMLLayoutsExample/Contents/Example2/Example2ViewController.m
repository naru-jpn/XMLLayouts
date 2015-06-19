
#import "Example2ViewController.h"

@interface Example2ViewController ()
@property (nonatomic) UIScrollView *scrollView;
@end

@implementation Example2ViewController

#pragma - action

- (void)onCloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:_scrollView];
    
    [_scrollView loadXMLLayoutsWithResourceName:@"Example2" completion:^(NSError *error){
        // add close action
        [_scrollView findViewByID:R.id(@"@id/close") work:^(UIView *view) {
            // add close action
            [(UIButton *)view addTarget:self action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            // adjust scroll view content size
            CGSize contentSize = _scrollView.containerWrappedSize;
            [_scrollView setContentSize:contentSize];
        }];
    }];
}

- (void)viewDidLayoutSubviews {
    [_scrollView refreshAllLayout];
    // adjust scroll view content size
    CGSize contentSize = _scrollView.containerWrappedSize;
    [_scrollView setContentSize:contentSize];
}

@end
