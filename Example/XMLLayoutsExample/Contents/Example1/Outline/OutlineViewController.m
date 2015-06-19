
#import "OutlineViewController.h"

@interface OutlineViewController ()
@property (nonatomic) UIScrollView *scrollView;
@end

@implementation OutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"_outline", nil)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:_scrollView];
    
    // load outline layouts on scroll view
    [_scrollView loadXMLLayoutsWithResourceName:@"Outline" completion:^(NSError *error) {
        CGSize contentSize = _scrollView.containerWrappedSize;
        [_scrollView setContentSize:contentSize];
    }];
}

- (void)viewDidLayoutSubviews {
    [_scrollView refreshAllLayout];
    CGSize contentSize = _scrollView.containerWrappedSize;
    [_scrollView setContentSize:contentSize];
}

@end
