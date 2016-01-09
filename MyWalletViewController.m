//
//  MyWalletViewController.m
//  yxz
//
//  Created by 白玉林 on 15/11/24.
//  Copyright © 2015年 zhirunjia.com. All rights reserved.
//

#import "MyWalletViewController.h"
#import "HuiYuanCenterController.h"
@interface MyWalletViewController ()
{
    UILabel *moneyLabel;
    UITableView *detailedTableView;
    NSArray *tableArray;
    UIView *balanceView;
    NSDictionary *balanceDic;
    UILabel *alertLabel;
}

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navlabel.text=@"我的钱包";
    balanceView=[[UIView alloc]initWithFrame:FRAME(0, 64, WIDTH, 70)];
    balanceView.backgroundColor=[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1];
    [self.view addSubview:balanceView];
    
    UILabel *balanceLabel=[[UILabel alloc]initWithFrame:FRAME(10, 55/2, 60, 15)];
    balanceLabel.text=@"余额(元):";
    balanceLabel.font=[UIFont fontWithName:@"Arial" size:13];
    balanceLabel.textColor=[UIColor whiteColor];
    balanceLabel.textAlignment=NSTextAlignmentRight;
    [balanceView addSubview:balanceLabel];
    
    [moneyLabel removeFromSuperview];
    moneyLabel=[[UILabel alloc]initWithFrame:FRAME(75, 55/2, WIDTH-155, 15)];
    
    UIButton *balanceBut=[[UIButton alloc]initWithFrame:FRAME(WIDTH-60, 20, 50, 30)];
    [balanceBut setTitle:@"充值" forState:UIControlStateNormal];
    [balanceBut setTitleColor:[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1] forState:UIControlStateNormal];
    balanceBut.backgroundColor=[UIColor whiteColor];
    [balanceBut addTarget:self action:@selector(balanceButAction) forControlEvents:UIControlEventTouchUpInside];
    [balanceView addSubview:balanceBut];
   
    // Do any additional setup after loading the view.
}

#pragma mark 获取用户详情接口成功返回数据
-(void)DetailsSuccessDown:(id)sender
{
    NSLog(@"%@",sender);
    balanceDic=[sender objectForKey:@"data"];
    [self moneyLayout];
    
}
#pragma mark 获取用户详情接口失败返回数据
-(void)DetailsFailureDown:(id)sender
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    ISLoginManager *_manager = [ISLoginManager shareManager];
    
    DownloadManager *money = [[DownloadManager alloc]init];
    NSDictionary *dic=@{@"user_id":_manager.telephone,@"view_user_id":_manager.telephone};
    [money requestWithUrl:USER_GRZY dict:dic view:self.view delegate:self finishedSEL:@selector(DetailsSuccessDown:) isPost:NO failedSEL:@selector(DetailsFailureDown:)];
    
    DownloadManager *_download = [[DownloadManager alloc]init];
    NSDictionary *_dicts = @{@"user_id":_manager.telephone,@"page":@"1"};
    [_download requestWithUrl:[NSString stringWithFormat:@"%@",USER_WALLET] dict:_dicts view:self.view delegate:self finishedSEL:@selector(DownloadFinish:) isPost:NO failedSEL:@selector(FailDownload:)];
}
#pragma mark 我的钱包积口访问成功返回方法
-(void)DownloadFinish:(id)sender
{
    NSLog(@"我的钱包返回方法%@",sender);
        tableArray=[sender objectForKey:@"data"];
    [detailedTableView removeFromSuperview];
    detailedTableView=[[UITableView alloc]initWithFrame:FRAME(0, 134, WIDTH, HEIGHT-134)];
    detailedTableView.dataSource=self;
    detailedTableView.delegate=self;
    detailedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:detailedTableView];
    
   // [v removeFromSuperview];
     UIView *v= [[UIView alloc] initWithFrame:CGRectZero];
    [detailedTableView setTableFooterView:v];

    NSString *string=[NSString stringWithFormat:@"%@",[sender objectForKey:@"status"]];
    if ([string isEqualToString:@"999"]) {
        [alertLabel removeFromSuperview];
        alertLabel=[[UILabel alloc]initWithFrame:FRAME((WIDTH-260)/2,200, 260, 40)];
        alertLabel.backgroundColor=[UIColor blackColor];
        alertLabel.alpha=0.4;
        alertLabel.text=[NSString stringWithFormat:@"%@",[sender objectForKey:@"msg"]];//@"还没有输入评论内容哦～";
        alertLabel.textColor=[UIColor whiteColor];
        alertLabel.textAlignment=NSTextAlignmentCenter;
        [self.view addSubview:alertLabel];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                         target:self
                                       selector:@selector(timerFireMethod:)
                                       userInfo:alertLabel
                                        repeats:NO];
    }

}
- (void)timerFireMethod:(NSTimer*)theTimer
{
    alertLabel.hidden=YES;
}
#pragma mark 我的钱包积口访问失败返回方法
-(void)FailDownload:(id)sender
{
    NSLog(@"访问钱包接口失败返回%@",sender);
}
#pragma mark 充值按钮点击方法
-(void)balanceButAction
{
    NSLog(@"我要充值");
    HuiYuanCenterController *huiYuanVC=[[HuiYuanCenterController alloc]init];
    [self.navigationController pushViewController:huiYuanVC animated:YES];
}
#pragma mark 余额显示方法
-(void)moneyLayout
{
    moneyLabel.text=[NSString stringWithFormat:@"%@",[balanceDic objectForKey:@"rest_money"]];
    moneyLabel.textAlignment=NSTextAlignmentLeft;
    moneyLabel.textColor=[UIColor whiteColor];
    moneyLabel.font=[UIFont fontWithName:@"Arial" size:13];
    [balanceView addSubview:moneyLabel];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return tableArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=tableArray[indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"（%ld,%ld)",(long)indexPath.row,(long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UILabel *moneyLab=[[UILabel alloc]init];
    UILabel *mobileLabel=[[UILabel alloc]init];
    UIView *lineView=[[UIView alloc]init];
    UILabel *textLabel=[[UILabel alloc]init];
    UILabel *timeLabel=[[UILabel alloc]init];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell addSubview:moneyLab];
        [cell addSubview:mobileLabel];
        [cell addSubview:textLabel];
        [cell addSubview:timeLabel];
        lineView.frame=FRAME(0, 50, WIDTH, 1);
        lineView.backgroundColor=[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:232/255.0f];
        [cell addSubview:lineView];
    }
    textLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"order_type_name"]];
    [textLabel setNumberOfLines:1];
    [textLabel sizeToFit];
    textLabel.font=[UIFont fontWithName:@"Arial" size:15];
    textLabel.textAlignment=NSTextAlignmentLeft;
    textLabel.frame=FRAME(10, 5, textLabel.frame.size.width, 22);
    
    timeLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"add_time_str"]];
    [timeLabel setNumberOfLines:1];
    [timeLabel sizeToFit];
    timeLabel.font=[UIFont fontWithName:@"Arial" size:12];
    timeLabel.textAlignment=NSTextAlignmentLeft;
    timeLabel.frame=FRAME(10, 32, timeLabel.frame.size.width, 15);
    
    NSString *textStr=[NSString stringWithFormat:@"%@",[dic objectForKey:@"order_pay"]];
    moneyLab.text=textStr;
    moneyLab.lineBreakMode=NSLineBreakByTruncatingTail;
    [moneyLab setNumberOfLines:1];
    [moneyLab sizeToFit];
    UIFont *font = [UIFont fontWithName:@"Arial" size:20];
    moneyLab.font=font;
    moneyLab.textAlignment=NSTextAlignmentRight;
   // moneyLab.backgroundColor=[UIColor redColor];
    CGSize size = CGSizeMake(320,22);
    CGSize labelsize = [textStr sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [moneyLab setFrame:CGRectMake(WIDTH-moneyLab.frame.size.width-10, 5, labelsize.width, labelsize.height)];
    //moneyLab.frame=FRAME(WIDTH-moneyLab.frame.size.width-10, 5, moneyLab.frame.size.width, moneyLab.frame.size.height);
    
    mobileLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"mobile"]];
    [mobileLabel setNumberOfLines:1];
    [mobileLabel sizeToFit];
    mobileLabel.font=[UIFont fontWithName:@"Arial" size:12];
    mobileLabel.textAlignment=NSTextAlignmentRight;
    mobileLabel.frame=FRAME(WIDTH-mobileLabel.frame.size.width-10, 32, mobileLabel.frame.size.width, 15);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
    //其他代码
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end