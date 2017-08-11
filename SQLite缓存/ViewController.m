//
//  ViewController.m
//  SQLite缓存
//
//  Created by caiyao's Mac on 2017/6/23.
//  Copyright © 2017年 core's Mac. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseManager.h"

#define WIN_SIZE [UIScreen mainScreen].bounds.size
static NSString *const cellID = @"cellid";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataLists;

@end

@implementation ViewController

-(UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, WIN_SIZE.width, WIN_SIZE.height - 20) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    [dbManager createTableWithSQL:@"CREATE TABLE IF NOT EXISTS news (id integer PRIMARY KEY AUTOINCREMENT, title text , detail text ,url text)"];
    for (int i = 0; i < 50; i ++)
    {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO news (id, title, detail, url) VALUES (%i, '%i新闻标题', '%i新闻详情', 'https://www.baidu.com')", i, i, i];
        [dbManager insert:sql];
    }
    
    NSArray *results = [dbManager search:@"SELECT id, title, detail, url FROM news"];
    if (results.count > 0)
    {
        self.dataLists = results;
        [self.tableView reloadData];
    }
    
    NSLog(@"%@", results);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataLists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = self.dataLists[indexPath.row][@"title"];
    cell.detailTextLabel.text = self.dataLists[indexPath.row][@"detail"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.dataLists[indexPath.row][@"url"]] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@(YES)} completionHandler:nil];
}
@end
