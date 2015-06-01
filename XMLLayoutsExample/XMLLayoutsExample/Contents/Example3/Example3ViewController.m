
#import "Example3ViewController.h"

@interface Example3ViewController ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *contents;
@property (nonatomic) UITableViewCell *stubCell;
@end

@implementation Example3ViewController

#pragma - action

- (void)onCloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setTableCellData:_contents[indexPath.row] forCell:_stubCell];
    return _stubCell.contentView.containerWrappedSize.height;
}

- (void)setTableCellData:(NSDictionary *)data forCell:(UITableViewCell *)cell {
    [cell.contentView findViewByID:R.id(@"@id/line") work:^(UIView *view) {
        [view setBackgroundColor:data[@"color"]];
    }];
    [cell.contentView findViewByID:R.id(@"@id/message") work:^(UIView *view) {
        [(UILabel *)view setText:data[@"message"]];
    }];
    [cell.contentView refreshAllLayoutWithAsynchronous:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [UITableViewCell new];
        [cell.contentView loadXMLLayoutsWithResourceName:@"TableCell" completion:^(NSError *error){
            [self setTableCellData:_contents[indexPath.row] forCell:cell];
        }];
    } else {
        [self setTableCellData:_contents[indexPath.row] forCell:cell];
    }
    return cell;
}

#pragma mark - create contents

- (void)createContents {
    NSArray *data = @[
        @{@"color": [XMLColorManager colorWithString:@"A07F"], @"message": NSLocalizedString(@"example3_content1", nil)},
        @{@"color": [XMLColorManager colorWithString:@"A7F0"], @"message": NSLocalizedString(@"example3_content2", nil)},
        @{@"color": [XMLColorManager colorWithString:@"AF07"], @"message": NSLocalizedString(@"example3_content3", nil)},
        @{@"color": [XMLColorManager colorWithString:@"A70F"], @"message": NSLocalizedString(@"example3_content4", nil)},
        @{@"color": [XMLColorManager colorWithString:@"A0F7"], @"message": NSLocalizedString(@"example3_content5", nil)},
    ];
    self.contents = [NSMutableArray array];
    for (NSInteger i=0; i < 30; i++) {
        [_contents addObject:data[arc4random()%5]];
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 20)];
    [_tableView setTableHeaderView:header];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 60)];
    [footer setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [footer setUserInteractionEnabled:YES];
    [footer loadXMLLayoutsWithResourceName:@"TableClose" completion:^(NSError *error){
        UIButton *button = (UIButton *)[footer viewWithID:R.id(@"@id/close")];
        [button addTarget:self action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }];
    [_tableView setTableFooterView:footer];
    
    [self createContents];
    _stubCell = [UITableViewCell new];
    [_stubCell.contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 0)];
    [_stubCell.contentView loadXMLLayoutsWithResourceName:@"TableCell" completion:^(NSError *error) {
        [_tableView reloadData];
    }];
}

- (void)viewDidLayoutSubviews {
    [_stubCell.contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 0)];
    [_tableView.tableFooterView refreshAllLayout];
    [_tableView reloadData];
}

@end
