//
//  ViewController.m
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import "ViewController.h"
#import "ISLoginManager.h"
#import "DownloadManager.h"
#import "PageTableViewCell.h"
#import "DetailsViewController.h"
#import "ShareFriendViewController.h"
#import "WXApi.h"
#import "MineViewController.h"
#import "QRcodeViewController.h"
#import "LBXScanViewStyle.h"
#import "LBXScanViewController.h"

#import "ClerkViewController.h"
#import "FountWebViewController.h"

@interface ViewController (){
    NSMutableDictionary *eventsByDate;
    UILabel *timeLabel;
    NSString *timeString;
    DownloadManager *_download;
    NSDictionary *_dict;
    UIView *viewMR;
    NSArray *numberArray;
    
    UIButton *foldingBut;
    UIView *OcclusionView;
    UISwipeGestureRecognizer *up;
    UISwipeGestureRecognizer *down;
    DetailsViewController *vc;
    
    
    UIScrollView *adView;
    NSArray *arrayImage;
    NSMutableArray *imageArray;
    UILabel *alertLabel;
    UIActivityIndicatorView *actView;
    NSString *dataString;
    UIPageControl *pageControl;
    NSTimer *timer;
    CLLocationManager *locationManager;
    NSString *senderString;
    
    NSArray *riliArray;
}

@end
CGFloat newHeight = 300;
int F=0,M=0,N=0,S,eyeID=0;
@implementation ViewController
@synthesize latString,lngString;
float lastContentOffset;
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"首页"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (vc.L==1) {
        _tableView.scrollEnabled =NO;
    }
//    [self rlLayout];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"首页"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    // 开始时时定位
    [locationManager startUpdatingLocation];
    
    
    
    actView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actView.center = CGPointMake(WIDTH/2, HEIGHT/2);
    actView.color = [UIColor blackColor];
    [actView startAnimating];
    [self.view addSubview:actView];
    imageArray=[[NSMutableArray alloc]init];
    
    self.view.backgroundColor=[UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    
    self.view.frame=FRAME(0, 0, WIDTH, HEIGHT-50);
//    foldingBut=[[UIButton alloc]initWithFrame:FRAME(WIDTH-60, 25, 40, 20)];
//    foldingBut.backgroundColor=[UIColor redColor];
//    foldingBut.layer.cornerRadius=5;
//    [foldingBut setTitle:@"展开" forState:UIControlStateNormal];
//    [foldingBut addTarget:self action:@selector(didChangeModeTouch) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    timeString=locationString;
    
    
    UIButton *myButton=[[UIButton alloc]initWithFrame:FRAME(15, 25, 30, 30)];
    [myButton addTarget:self action:@selector(myButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *myImage=[[UIImageView alloc]initWithFrame:FRAME(5, 5, 20, 20)];
    myImage.image=[UIImage imageNamed:@"GRZX_BT"];
    [myButton addSubview:myImage];
    
    UIButton *eyeButton=[[UIButton alloc]initWithFrame:FRAME(15, 25, 30, 30)];
    [eyeButton addTarget:self action:@selector(eyeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:eyeButton];
    
    UIImageView *eyeImage=[[UIImageView alloc]initWithFrame:FRAME(5, 5, 20, 20)];
    eyeImage.image=[UIImage imageNamed:@"iconfont-saoma"];//EYE_BT
    [eyeButton addSubview:eyeImage];
    
    UIButton *calenderButton=[[UIButton alloc]initWithFrame:FRAME(WIDTH-45, 25, 30, 30)];
    [calenderButton addTarget:self action:@selector(didChangeModeTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calenderButton];
    
    UIImageView *calenderImage=[[UIImageView alloc]initWithFrame:FRAME(5, 5, 20, 20)];
    calenderImage.image=[UIImage imageNamed:@"RL_BT"];
    [calenderButton addSubview:calenderImage];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    riliArray=delegate.riliArray;
//    
//    NSDateFormatter  *yerformatter=[[NSDateFormatter alloc] init];
//    [yerformatter setDateFormat:@"yyyy"];
//    NSString *  yearStr=[yerformatter stringFromDate:senddate];
//
//    NSDateFormatter  *monthformatter=[[NSDateFormatter alloc] init];
//    [monthformatter setDateFormat:@"MM"];
//    NSString *  monthStr=[monthformatter stringFromDate:senddate];
//
//    
//    ISLoginManager *_manager = [ISLoginManager shareManager];
//    DownloadManager *download = [[DownloadManager alloc]init];
//    NSDictionary *dict=@{@"user_id":_manager.telephone,@"year":yearStr,@"month":monthStr};
//    [download requestWithUrl:@"simi/app/card/total_by_month.json"  dict:dict view:self.view delegate:self finishedSEL:@selector(RiLiSuccess:) isPost:NO failedSEL:@selector(RiLiFailure:)];
    [self rlLayout];
   
}
-(void)RiLiSuccess:(id)sender
{
    riliArray=[sender objectForKey:@"data"];
    
    
}
-(void)RiLiFailure:(id)sender
{
    NSLog(@"日历布局失败返回:%@",sender);
}
#pragma mark日历
-(void)rlLayout
{
    
    self.calendar = [JTCalendar new];
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld\n%@", (long)comps.year, monthText];
        };
    }
    OcclusionView=[[UIView alloc]initWithFrame:FRAME(0, 0, WIDTH, _tableView.frame.size.height)];
    OcclusionView.backgroundColor=[UIColor blueColor];
    OcclusionView.userInteractionEnabled=YES;
    [_tableView addSubview:OcclusionView];
    OcclusionView.hidden=YES;
    
    
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
    [self createRandomEvents];
    
    [self.calendar reloadData];
    
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    [self transitionExample];
    
    [self tableViewLayout];

}
#pragma mark 首页右上按钮点击方法
-(void)eyeButtonAction:(UIButton *)button
{
    NSArray *arrayItems = @[@[@"模拟qq扫码界面",@"qqStyle"]];
    NSArray* array = arrayItems[0];
    NSString *methodName = [array lastObject];
    
    SEL normalSelector = NSSelectorFromString(methodName);
    if ([self respondsToSelector:normalSelector]) {
        
        ((void (*)(id, SEL))objc_msgSend)(self, normalSelector);
    }

}
#pragma mark -模仿qq界面
- (void)qqStyle
{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    style.animationImage = imgLine;
    
    LBXScanViewController *lBvc = [LBXScanViewController new];
    lBvc.style = style;
    lBvc.isQQSimulator = YES;
    [self.navigationController pushViewController:lBvc animated:YES];
}
-(void)tableViewLayout
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, newHeight+70, WIDTH,HEIGHT-newHeight-119)];
    self.tableView.separatorStyle=UITableViewCellSelectionStyleNone;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor colorWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1];
    [self.view addSubview:self.tableView];
    NSLog(@"数组个数%lu",(unsigned long)numberArray.count);
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor=[UIColor whiteColor];
    [_tableView setTableFooterView:v];

}
#pragma mark 首页左上按钮点击方法
-(void)myButtonAction:(UIButton *)button
{
    MineViewController *mineVC=[[MineViewController alloc]init];
    [self.navigationController pushViewController:mineVC animated:YES];
    
}
#pragma mark广告未View布局及初始化
-(void)adViewLayout
{
    [adView removeFromSuperview];
    adView=[[UIScrollView alloc]initWithFrame:FRAME(0, newHeight+70, WIDTH, (WIDTH*0.42+40))];
    adView.bounces=NO;
    adView.delegate=self;
    adView.pagingEnabled = YES;
    adView.showsHorizontalScrollIndicator = NO;
    adView.contentSize=CGSizeMake(WIDTH*arrayImage.count, WIDTH*0.42+40);
        //[self.view addSubview:adView];
    for (int i=0; i<arrayImage.count; i++) {
        NSDictionary *dic=arrayImage[i];
        UIButton *viewImage=[[UIButton alloc]initWithFrame:FRAME(WIDTH*i, 0, WIDTH, (WIDTH*0.42+40))];
        viewImage.backgroundColor=[UIColor whiteColor];
        [viewImage addTarget:self action:@selector(butAction:) forControlEvents:UIControlEventTouchUpInside];
        viewImage.tag=i;
        [adView addSubview:viewImage];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:FRAME(0, 0, WIDTH, WIDTH*0.42)];
        NSString *imageUrl=[NSString stringWithFormat:@"%@",[dic objectForKey:@"img_url"]];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:nil];
        [viewImage addSubview:imageView];
        UILabel *textLabel=[[UILabel alloc]initWithFrame:FRAME(20, WIDTH*0.42, WIDTH-30, 40)];
        textLabel.textAlignment=NSTextAlignmentCenter;
        textLabel.textColor=[UIColor colorWithRed:150/255.0f green:150/255.0f blue:150/255.0f alpha:1];
        textLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
        [viewImage addSubview:textLabel];
    }
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(WIDTH-5*arrayImage.count-10*(arrayImage.count+1), WIDTH*0.42+newHeight+70, 5*arrayImage.count+10*(arrayImage.count+1), 30)];
    pageControl.numberOfPages = arrayImage.count;
    pageControl.alpha=0.5;
    pageControl.backgroundColor=[UIColor whiteColor];
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    [self addTimer];

}
-(void)butAction:(UIButton *)sender
{
    NSDictionary *dic=arrayImage[sender.tag];
    NSString *string=[NSString stringWithFormat:@"%@",[dic objectForKey:@"goto_type"]];
    if ([string isEqualToString:@"app"]) {
        ClerkViewController *clerkVC=[[ClerkViewController alloc]init];
        clerkVC.service_type_id=[NSString stringWithFormat:@"%@",[dic objectForKey:@"service_type_ids"]];
        [self.navigationController pushViewController:clerkVC animated:YES];
    }else{
        FountWebViewController *fountVC=[[FountWebViewController alloc]init];
        fountVC.goto_type=[NSString stringWithFormat:@"%@",[dic objectForKey:@"goto_type"]];
        fountVC.imgurl=[NSString stringWithFormat:@"%@",[dic objectForKey:@"goto_url"]];
        fountVC.service_type_id=[NSString stringWithFormat:@"%@",[dic objectForKey:@"service_type_ids"]];
        [self.navigationController pushViewController:fountVC animated:YES];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    pageControl.currentPage = scrollView1.contentOffset.x/WIDTH;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

-(void)addTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
}

-(void)nextPage
{
    long page = pageControl.currentPage;
    if (page == arrayImage.count - 1) {
        page =0;
        CGFloat offsetX = page * adView.frame.size.width;
        CGPoint offset = CGPointMake(offsetX, 0);
        [adView setContentOffset:offset animated:NO];
    }
    else {
        page = pageControl.currentPage + 1;
        CGFloat offsetX = page * adView.frame.size.width;
        CGPoint offset = CGPointMake(offsetX, 0);
        [adView setContentOffset:offset animated:YES];
    }
    
}

-(void)removeTimer
{
    [timer invalidate];
    timer = nil;
}


-(void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
    DownloadManager *download = [[DownloadManager alloc]init];
    NSDictionary *dict=@{@"channel_id":@"0"};
    [download requestWithUrl:CHANNEL_CARD dict:dict view:self.view delegate:self finishedSEL:@selector(ChannelSuccess:) isPost:NO failedSEL:@selector(ChannelFailure:)];
    
}

#pragma mark 获取频道列表成功返回方法
-(void)ChannelSuccess:(id)sender
{
    NSLog(@"获取频道列表成功数据%@",sender);
    arrayImage=[sender objectForKey:@"data"];
    dataString=[NSString stringWithFormat:@"%@",[sender objectForKey:@"data"]];
    if (dataString==nil||dataString==NULL||dataString.length==0||[dataString isEqualToString:@""]) {
        [actView stopAnimating]; // 结束旋转
        [actView setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [alertLabel removeFromSuperview];
        alertLabel=[[UILabel alloc]initWithFrame:FRAME((WIDTH-260)/2,HEIGHT-200, 260, 40)];
        alertLabel.backgroundColor=[UIColor blackColor];
        alertLabel.alpha=0.4;
        alertLabel.text=[NSString stringWithFormat:@"没有数据%@",[sender objectForKey:@"msg"]];//@"还没有输入评论内容哦～";
        alertLabel.textColor=[UIColor whiteColor];
        alertLabel.textAlignment=NSTextAlignmentCenter;
        //[self.view addSubview:alertLabel];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                         target:self
                                       selector:@selector(timerFireMethod:)
                                       userInfo:alertLabel
                                        repeats:NO];
        
    }else{
        [actView stopAnimating]; // 结束旋转
        [actView setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [self adViewLayout];
    }
    
    
    ISLoginManager *_manager = [ISLoginManager shareManager];
    _download = [[DownloadManager alloc]init];
    NSLog(@"%@,,%@",lngString,latString);
    if ((lngString==nil&&latString==nil)||(lngString==NULL&&latString==NULL)) {
        lngString=@"";
        latString=@"";
    }
    _dict =@{@"service_date":timeString,@"user_id":_manager.telephone,@"card_from":@"0",@"page":@"1",@"lng":lngString,@"lat":latString};
    NSLog(@"字典数据%@",_dict);
    [_download requestWithUrl:CARD_LIST dict:_dict view:self.tableView delegate:self finishedSEL:@selector(logDowLoadFinish:) isPost:NO failedSEL:@selector(DownFail:)];

    
    
}

// 错误信息
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error");
    NSString *errorString;
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }

}

// 6.0 以上调用这个函数
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"%lu", (unsigned long)[locations count]);
    
    CLLocation *newLocation = locations[0];
    CLLocationCoordinate2D oldCoordinate= newLocation.coordinate;
    NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);
    lngString=[NSString stringWithFormat:@"%f",oldCoordinate.longitude];
    latString=[NSString stringWithFormat:@"%f",oldCoordinate.latitude];
    [manager stopUpdatingLocation];
    
}

// 6.0 调用此函数
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"%@", @"ok");
}


#pragma mark 获取频道列表失败返回方法
-(void)ChannelFailure:(id)sender
{
    NSLog(@"获取频道列表失败数据%@",sender);
}
- (void)timerFireMethod:(NSTimer*)theTimer
{
    alertLabel.hidden=YES;
}

-(void)logDowLoadFinish:(id)sender
{
    
    NSLog(@"登录后信息：%@",sender);
    senderString=[NSString stringWithFormat:@"%@",[sender objectForKey:@"data"]];
    //if([tmpStr1 isEqualToString:tmpStr2])
    
    
//    [self.tableView removeFromSuperview];
    [viewMR removeFromSuperview];
    viewMR=[[UIView alloc]initWithFrame:CGRectMake(0.0f, newHeight+70, WIDTH,HEIGHT-newHeight-119)];
    viewMR.backgroundColor=[UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:FRAME((WIDTH-100)/2, 40, 100, 100)];
    imageView.image=[UIImage imageNamed:@"家-服务单-无订单_03"];
    [viewMR addSubview:imageView];
    UILabel *la=[[UILabel alloc]init];
    la.text=@"貌似这天你没事哦~";
    la.textAlignment=NSTextAlignmentCenter;
    la.lineBreakMode=NSLineBreakByTruncatingTail;
    [la setNumberOfLines:1];
    [la sizeToFit];
    la.frame=FRAME(20, imageView.frame.origin.y+imageView.frame.size.height, WIDTH-40, 20);
    la.textColor=[UIColor colorWithRed:106/255.0f green:106/255.0f blue:106/255.0f alpha:1];
    //la.backgroundColor=[UIColor redColor];
    [viewMR addSubview:la];
    
    
  
    if ([senderString isEqualToString:@""]) {
        numberArray=nil;
    }else{
        numberArray=[sender objectForKey:@"data"];
    }
    _tableView.frame=CGRectMake(0, newHeight+70, WIDTH,HEIGHT-newHeight-119);
    self.tableView.tableHeaderView=adView;
    [self.view addSubview:self.tableView];
    [_tableView reloadData];
    if ((dataString==nil||dataString==NULL||dataString.length==0||[dataString isEqualToString:@""])&&[senderString isEqualToString:@""]){
        viewMR.hidden=NO;
        [self.view addSubview:viewMR];
    }else{
        viewMR.hidden=YES;
        
    }
}
-(void)DownFail:(id)sender
{
    NSLog(@"erroe is %@",sender);
}

- (void)viewDidLayoutSubviews
{
    [self.calendar repositionViews];
}

#pragma mark - Buttons callback

- (void)didGoTodayTouch
{
    [self.calendar setCurrentDate:[NSDate date]];
}

- (void)didChangeModeTouch
{
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    [self transitionExample];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *  locationString=[dateformatter stringFromDate:date];
    timeString=locationString;
    NSLog(@"Date: %@ events", locationString);
    ISLoginManager *_manager = [ISLoginManager shareManager];
    if ((lngString==nil&&latString==nil)||(lngString==NULL&&latString==NULL)) {
        lngString=@"";
        latString=@"";
    }
    _dict =@{@"service_date":timeString,@"user_id":_manager.telephone,@"card_from":@"0",@"page":@"1",@"lng":lngString,@"lat":latString};
    NSLog(@"字典数据%@",_dict);
    [_download requestWithUrl:CARD_LIST dict:_dict view:self.tableView delegate:self finishedSEL:@selector(logDowLoadFinish:) isPost:NO failedSEL:@selector(DownFail:)];
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
}

#pragma mark - Transition examples

- (void)transitionExample
{
    
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75;
        [foldingBut setTitle:@"展开" forState:UIControlStateNormal];
    }else
    {
        newHeight = 300;
        [foldingBut setTitle:@"收起" forState:UIControlStateNormal];
    }
    [self scrollLayout];
}

-(void)scrollLayout
{
    [UIView animateWithDuration:.5
                     animations:^{
                         [UIView beginAnimations:nil context:nil];
                         //设置动画时长
                         [UIView setAnimationDuration:0.5];
                         self.calendarContentViewHeight.constant = newHeight;
                         [UIView commitAnimations];
                         
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
    [UIView beginAnimations:nil context:nil];
    //设置动画时长
    [UIView setAnimationDuration:0.5];
    adView.frame=FRAME(0, newHeight+70, WIDTH, WIDTH*0.42+40);
    if (dataString==nil||dataString==NULL||dataString.length==0||[dataString isEqualToString:@""]){
       viewMR.frame=CGRectMake(0.0f, newHeight+70, WIDTH,HEIGHT-newHeight-119);
        self.tableView.frame=CGRectMake(0.0f, newHeight+70, WIDTH,HEIGHT-newHeight-119);
    }else{
        viewMR.frame=CGRectMake(0.0f, newHeight+70, WIDTH,HEIGHT-newHeight-119);
        self.tableView.frame=CGRectMake(0.0f, newHeight+70, WIDTH,HEIGHT-newHeight-119);
    }
    
    
    
    [UIView commitAnimations];
    
}
#pragma mark - Fake data

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-dd-MM";
    }
    
    return dateFormatter;
}

- (void)createRandomEvents
{
    eventsByDate = [NSMutableDictionary new];
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    riliArray=delegate.riliArray;
    for(int i = 0; i < riliArray.count; ++i){
        NSDictionary *dic=riliArray[i];
        NSString *riliStr=[NSString stringWithFormat:@"%@ 07:10:00",[dic objectForKey:@"service_date"]];
        NSString *theFirstTime1=[NSString stringWithFormat:@"%@",riliStr];
        NSDateFormatter *theFirstformatte1 = [[NSDateFormatter alloc] init];
        [theFirstformatte1 setDateStyle:NSDateFormatterMediumStyle];
        [theFirstformatte1 setTimeStyle:NSDateFormatterShortStyle];
        [theFirstformatte1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* theFirstdate1 = [theFirstformatte1 dateFromString:theFirstTime1];
//        NSDate *randomDate = [theFirstformatte1 dateFromString:theFirstTime1];//[NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        NSString *key = [[self dateFormatter] stringFromDate:theFirstdate1];
        
        if(!eventsByDate[key]){
            eventsByDate[key] = [NSMutableArray new];
        }
             
        [eventsByDate[key] addObject:theFirstdate1];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numberArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic=numberArray[indexPath.row];
    NSString *identifier =[NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    int card_type_Id=[[dic objectForKey:@"card_type"]intValue];
#pragma mark 以下是判断天气图片显示的时间值
    NSDictionary *dict;
    NSDictionary *textDic;
    NSArray *array;
    NSTimeInterval _secondDate = 0.0;
    NSTimeInterval theFirst1 = 0.0;
    if (card_type_Id==99) {
        NSString *jsonString=[NSString stringWithFormat:@"%@",[dic objectForKey:@"card_extra"]];
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSLog(@"%@",dict);
        if(err) {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        textDic=[dict objectForKey:@"weatherIndex"];
        array=[dict objectForKey:@"weatherDatas"];
        //获取当前时间
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *  locationString=[dateformatter stringFromDate:senddate];
        NSLog(@"locationString:%@",locationString);
        NSDateFormatter *formatte = [[NSDateFormatter alloc] init];
        [formatte setDateStyle:NSDateFormatterMediumStyle];
        [formatte setTimeStyle:NSDateFormatterShortStyle];
        [formatte setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* date = [formatte dateFromString:locationString];
        _secondDate = [date timeIntervalSince1970]*1;
        //获取当前时间
        //当前时间第一个时间段
        NSString *theFirstTime1=[NSString stringWithFormat:@"%@ 18:00:00",[locationString substringWithRange:NSMakeRange(0,10)]];
        NSDateFormatter *theFirstformatte1 = [[NSDateFormatter alloc] init];
        [theFirstformatte1 setDateStyle:NSDateFormatterMediumStyle];
        [theFirstformatte1 setTimeStyle:NSDateFormatterShortStyle];
        [theFirstformatte1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* theFirstdate1 = [theFirstformatte1 dateFromString:theFirstTime1];
        theFirst1 = [theFirstdate1 timeIntervalSince1970]*1;
    }
#pragma mark 以上是判断天气图片显示的时间值
    PageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault   reuseIdentifier:identifier];
        NSString *clString=[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]];
        int clID=[clString intValue];
        if (card_type_Id==99) {
            cell.promptlabel.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"cityName"]];
            cell.promptlabel.textColor=[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1];
        }else{
            if (clID==1) {
                cell.promptlabel.text=@"处理中";
                cell.promptlabel.textColor=[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1];
            }else if (clID==2){
                cell.promptlabel.text=@"秘书处理中";
                cell.promptlabel.textColor=[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1];
            }else if(clID==3){
                cell.promptlabel.text=@"已完成";
                cell.promptlabel.textColor=[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1];
            }else if (clID==0){
                cell.promptlabel.text=@"已取消";
                cell.promptlabel.textColor=[UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1];
            }
        }
        [cell.promptlabel setNumberOfLines:1];
        [cell.promptlabel sizeToFit];
        cell.promptlabel.frame=CGRectMake(WIDTH-cell.promptlabel.frame.size.width-15 ,14,cell.promptlabel.frame.size.width,55-26);
        UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(cell.promptlabel.frame.size.width, 0, 10, cell.promptlabel.frame.size.height)];
        image.image=[UIImage imageNamed:@"SYCELL_YHB_@2x"];
        [cell.promptlabel addSubview:image];
        UIImageView *image2=[[UIImageView alloc]initWithFrame:CGRectMake(-20, 0, cell.promptlabel.frame.size.width+20, cell.promptlabel.frame.size.height)];
        image2.image=[UIImage imageNamed:@"SYCELL_YHBY_@2x"];
        [cell.promptlabel addSubview:image2];
        
    }
    
    
    NSArray *headImageArray=@[@"HYXQ_HEAD",@"MSJZ_HEAD",@"SWTX_HEAD",@"YYTZ_HEAD",@"CLGH_HEAD"];
    NSArray *headArray=@[@"HY",@"JZ",@"SW",@"YYTZ",@"CL"];
    if (card_type_Id==99) {
        cell.titleLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"card_type_name"]];
    }else{
        cell.titleLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"card_type_name"]];
    }
    
    [cell.titleLabel setNumberOfLines:1];
    [cell.titleLabel sizeToFit];
    
    cell.timeLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"add_time_str"]];
    [cell.timeLabel setNumberOfLines:1];
    [cell.timeLabel sizeToFit];
    
    if (card_type_Id==1) {
        cell.heideImage.image=[UIImage imageNamed:headArray[card_type_Id-1]];
        cell.descriptionView.image=[UIImage imageNamed:headImageArray[card_type_Id-1]];
        [cell.descriptionView setContentMode:UIViewContentModeScaleAspectFit];
        cell.sjLabel.text=@"时间:";
        [cell.sjLabel setNumberOfLines:1];
        [cell.sjLabel sizeToFit];
        cell.sjLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.sjLabel.frame=CGRectMake(129, 13, cell.sjLabel.frame.size.width, 14);
        
        cell.moneyLabel.text=@"会议地点:";
        [cell.moneyLabel setNumberOfLines:1];
        [cell.moneyLabel sizeToFit];
        cell.moneyLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.moneyLabel.frame=CGRectMake(129, 36, cell.moneyLabel.frame.size.width, 14);
        
        cell.address.hidden=NO;
        cell.address.text=@"提醒人:";
        [cell.address setNumberOfLines:1];
        [cell.address sizeToFit];
        cell.address.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.address.frame=CGRectMake(129, 59, cell.address.frame.size.width, 14);
        
        double inTime=[[dic objectForKey:@"service_time"] doubleValue];
        NSDateFormatter* inTimeformatter =[[NSDateFormatter alloc] init];
        inTimeformatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [inTimeformatter setDateStyle:NSDateFormatterMediumStyle];
        [inTimeformatter setTimeStyle:NSDateFormatterShortStyle];
        [inTimeformatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
        NSDate* inTimedate = [NSDate dateWithTimeIntervalSince1970:inTime];
        NSString* inTimeString = [inTimeformatter stringFromDate:inTimedate];
        
        cell.inTimeLabel.text=[NSString stringWithFormat:@"%@",inTimeString];
        cell.inTimeLabel.frame=CGRectMake(cell.sjLabel.frame.size.width+cell.sjLabel.frame.origin.x, 13, WIDTH-148-cell.sjLabel.frame.size.width, 14);
        
        cell.costLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"service_addr"]];
        cell.costLabel.frame=CGRectMake(cell.moneyLabel.frame.size.width+cell.moneyLabel.frame.origin.x, 36, WIDTH-148-cell.moneyLabel.frame.size.width, 14);
        NSArray *nameArray=[dic objectForKey:@"attends"];
        NSMutableArray *nameArr=[[NSMutableArray alloc]init];
        for (int i=0; i<nameArray.count; i++) {
            NSString *nameString=[NSString stringWithFormat:@"%@",[nameArray[i] objectForKey:@"name"]];
            [nameArr addObject:nameString];
        }
        NSString *personnel=[nameArr componentsJoinedByString:@","];
        cell.addressLabel.hidden=NO;
        cell.addressLabel.text=[NSString stringWithFormat:@"%@",personnel];
        [cell.addressLabel setNumberOfLines:1];
        [cell.addressLabel sizeToFit];
        cell.addressLabel.lineBreakMode=NSLineBreakByTruncatingTail;

        cell.addressLabel.frame=CGRectMake(cell.address.frame.size.width+cell.address.frame.origin.x, 59, WIDTH-148-cell.address.frame.size.width, 14);
        
    }else if (card_type_Id==2){
        cell.heideImage.image=[UIImage imageNamed:headArray[card_type_Id-1]];
        cell.descriptionView.image=[UIImage imageNamed:headImageArray[card_type_Id-1]];
        [cell.descriptionView setContentMode:UIViewContentModeScaleAspectFit];
        cell.sjLabel.text=@"时间:";
        [cell.sjLabel setNumberOfLines:1];
        [cell.sjLabel sizeToFit];
        cell.sjLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.sjLabel.frame=CGRectMake(129, 13, cell.sjLabel.frame.size.width, 14);
        
        cell.moneyLabel.text=@"提醒人:";
        [cell.moneyLabel setNumberOfLines:1];
        [cell.moneyLabel sizeToFit];
        cell.moneyLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.moneyLabel.frame=CGRectMake(129, 36, cell.moneyLabel.frame.size.width, 14);
        
        cell.address.hidden=YES;
        cell.address.text=@"提醒人:";
        [cell.address setNumberOfLines:1];
        [cell.address sizeToFit];
        cell.address.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.address.frame=CGRectMake(129, 59, cell.address.frame.size.width, 14);
        
        double inTime=[[dic objectForKey:@"service_time"] doubleValue];
        NSDateFormatter* inTimeformatter =[[NSDateFormatter alloc] init];
        inTimeformatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [inTimeformatter setDateStyle:NSDateFormatterMediumStyle];
        [inTimeformatter setTimeStyle:NSDateFormatterShortStyle];
        [inTimeformatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
        NSDate* inTimedate = [NSDate dateWithTimeIntervalSince1970:inTime];
        NSString* inTimeString = [inTimeformatter stringFromDate:inTimedate];
        
        cell.inTimeLabel.text=[NSString stringWithFormat:@"%@",inTimeString];
        cell.inTimeLabel.frame=CGRectMake(cell.sjLabel.frame.size.width+cell.sjLabel.frame.origin.x, 13, WIDTH-148-cell.sjLabel.frame.size.width, 14);
        
        NSArray *nameArray=[dic objectForKey:@"attends"];
        NSMutableArray *nameArr=[[NSMutableArray alloc]init];
        for (int i=0; i<nameArray.count; i++) {
            NSString *nameString=[NSString stringWithFormat:@"%@",[nameArray[i] objectForKey:@"name"]];
            [nameArr addObject:nameString];
        }
        NSString *personnel=[nameArr componentsJoinedByString:@","];
        cell.costLabel.text=[NSString stringWithFormat:@"%@",personnel];
        cell.costLabel.frame=CGRectMake(cell.moneyLabel.frame.size.width+cell.moneyLabel.frame.origin.x, 36, WIDTH-148-cell.moneyLabel.frame.size.width, 14);
        cell.addressLabel.hidden=YES;
        
    }else if (card_type_Id==3){
        cell.heideImage.image=[UIImage imageNamed:headArray[card_type_Id-1]];
        cell.descriptionView.image=[UIImage imageNamed:headImageArray[card_type_Id-1]];
        [cell.descriptionView setContentMode:UIViewContentModeScaleAspectFit];
        cell.sjLabel.text=@"时间:";
        [cell.sjLabel setNumberOfLines:1];
        [cell.sjLabel sizeToFit];
        cell.sjLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.sjLabel.frame=CGRectMake(129, 13, cell.sjLabel.frame.size.width, 14);
        
        cell.moneyLabel.text=@"提醒人:";
        [cell.moneyLabel setNumberOfLines:1];
        [cell.moneyLabel sizeToFit];
        cell.moneyLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.moneyLabel.frame=CGRectMake(129, 36, cell.moneyLabel.frame.size.width, 14);
        
        cell.address.hidden=YES;
        cell.address.text=@"提醒人:";
        [cell.address setNumberOfLines:1];
        [cell.address sizeToFit];
        cell.address.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.address.frame=CGRectMake(129, 59, cell.address.frame.size.width, 14);
        
        double inTime=[[dic objectForKey:@"service_time"] doubleValue];
        NSDateFormatter* inTimeformatter =[[NSDateFormatter alloc] init];
        inTimeformatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [inTimeformatter setDateStyle:NSDateFormatterMediumStyle];
        [inTimeformatter setTimeStyle:NSDateFormatterShortStyle];
        [inTimeformatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
        NSDate* inTimedate = [NSDate dateWithTimeIntervalSince1970:inTime];
        NSString* inTimeString = [inTimeformatter stringFromDate:inTimedate];
        
        cell.inTimeLabel.text=[NSString stringWithFormat:@"%@",inTimeString];
        cell.inTimeLabel.frame=CGRectMake(cell.sjLabel.frame.size.width+cell.sjLabel.frame.origin.x, 13, WIDTH-148-cell.sjLabel.frame.size.width, 14);
        
        NSArray *nameArray=[dic objectForKey:@"attends"];
        NSMutableArray *nameArr=[[NSMutableArray alloc]init];
        for (int i=0; i<nameArray.count; i++) {
            NSString *nameString=[NSString stringWithFormat:@"%@",[nameArray[i] objectForKey:@"name"]];
            [nameArr addObject:nameString];
        }
        NSString *personnel=[nameArr componentsJoinedByString:@","];
        cell.costLabel.text=[NSString stringWithFormat:@"%@",personnel];
        cell.costLabel.frame=CGRectMake(cell.moneyLabel.frame.size.width+cell.moneyLabel.frame.origin.x, 36, WIDTH-148-cell.moneyLabel.frame.size.width, 14);
        
        cell.addressLabel.hidden=YES;
    }else if (card_type_Id==4){
        cell.heideImage.image=[UIImage imageNamed:headArray[card_type_Id-1]];
        cell.descriptionView.image=[UIImage imageNamed:headImageArray[card_type_Id-1]];
        [cell.descriptionView setContentMode:UIViewContentModeScaleAspectFit];
        cell.sjLabel.text=@"时间:";
        [cell.sjLabel setNumberOfLines:1];
        [cell.sjLabel sizeToFit];
        cell.sjLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.sjLabel.frame=CGRectMake(129, 13, cell.sjLabel.frame.size.width, 14);
        
        cell.moneyLabel.text=@"邀约人:";
        [cell.moneyLabel setNumberOfLines:1];
        [cell.moneyLabel sizeToFit];
        cell.moneyLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.moneyLabel.frame=CGRectMake(129, 36, cell.moneyLabel.frame.size.width, 14);
        
        cell.address.hidden=YES;
        cell.address.text=@"提醒人:";
        [cell.address setNumberOfLines:1];
        [cell.address sizeToFit];
        cell.address.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.address.frame=CGRectMake(129, 59, cell.address.frame.size.width, 14);
        
        double inTime=[[dic objectForKey:@"service_time"] doubleValue];
        NSDateFormatter* inTimeformatter =[[NSDateFormatter alloc] init];
        inTimeformatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [inTimeformatter setDateStyle:NSDateFormatterMediumStyle];
        [inTimeformatter setTimeStyle:NSDateFormatterShortStyle];
        [inTimeformatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
        NSDate* inTimedate = [NSDate dateWithTimeIntervalSince1970:inTime];
        NSString* inTimeString = [inTimeformatter stringFromDate:inTimedate];
        
        cell.inTimeLabel.text=[NSString stringWithFormat:@"%@",inTimeString];
        cell.inTimeLabel.frame=CGRectMake(cell.sjLabel.frame.size.width+cell.sjLabel.frame.origin.x, 13, WIDTH-148-cell.sjLabel.frame.size.width, 14);
        
        NSArray *nameArray=[dic objectForKey:@"attends"];
        NSMutableArray *nameArr=[[NSMutableArray alloc]init];
        for (int i=0; i<nameArray.count; i++) {
            NSString *nameString=[NSString stringWithFormat:@"%@",[nameArray[i] objectForKey:@"name"]];
            [nameArr addObject:nameString];
        }
        NSString *personnel=[nameArr componentsJoinedByString:@","];
        cell.costLabel.text=[NSString stringWithFormat:@"%@",personnel];
        cell.costLabel.frame=CGRectMake(cell.moneyLabel.frame.size.width+cell.moneyLabel.frame.origin.x, 36, WIDTH-148-cell.moneyLabel.frame.size.width, 14);
        
        cell.addressLabel.hidden=YES;
    }else if (card_type_Id==5){
        cell.heideImage.image=[UIImage imageNamed:headArray[card_type_Id-1]];
        cell.descriptionView.image=[UIImage imageNamed:headImageArray[card_type_Id-1]];
        [cell.descriptionView setContentMode:UIViewContentModeScaleAspectFit];
        cell.sjLabel.text=@"城市:";
        [cell.sjLabel setNumberOfLines:1];
        [cell.sjLabel sizeToFit];
        cell.sjLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.sjLabel.frame=CGRectMake(129, 13, cell.sjLabel.frame.size.width, 14);
        
        cell.moneyLabel.text=@"时间:";
        [cell.moneyLabel setNumberOfLines:1];
        [cell.moneyLabel sizeToFit];
        cell.moneyLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.moneyLabel.frame=CGRectMake(129, 36, cell.moneyLabel.frame.size.width, 14);
        
        cell.address.text=@"航班:";
        [cell.address setNumberOfLines:1];
        [cell.address sizeToFit];
        cell.address.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.address.frame=CGRectMake(129, 59, cell.address.frame.size.width, 14);
        
        double inTime=[[dic objectForKey:@"service_time"] doubleValue];
        NSDateFormatter* inTimeformatter =[[NSDateFormatter alloc] init];
        inTimeformatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [inTimeformatter setDateStyle:NSDateFormatterMediumStyle];
        [inTimeformatter setTimeStyle:NSDateFormatterShortStyle];
        [inTimeformatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
        NSDate* inTimedate = [NSDate dateWithTimeIntervalSince1970:inTime];
        NSString* inTimeString = [inTimeformatter stringFromDate:inTimedate];
        
        NSString *fromCityName=[NSString stringWithFormat:@"%@",[dic objectForKey:@"ticket_from_city_name"]];
        NSLog(@"出发%@",fromCityName);
        NSString *toCityName=[NSString stringWithFormat:@"%@",[dic objectForKey:@"ticket_to_city_name"]];
        NSString *cityName=[NSString stringWithFormat:@"从 %@ 到 %@",fromCityName,toCityName];
        cell.inTimeLabel.text=[NSString stringWithFormat:@"%@",cityName];
        cell.inTimeLabel.frame=CGRectMake(cell.sjLabel.frame.size.width+cell.sjLabel.frame.origin.x, 13, WIDTH-148-cell.sjLabel.frame.size.width, 14);
        
        cell.costLabel.text=[NSString stringWithFormat:@"%@",inTimeString];
        NSLog(@"%@",inTimeString);
        cell.costLabel.frame=CGRectMake(cell.moneyLabel.frame.size.width+cell.moneyLabel.frame.origin.x, 36, WIDTH-148-cell.moneyLabel.frame.size.width, 14);
        cell.addressLabel.text=[NSString stringWithFormat:@"航班"];
        cell.addressLabel.frame=CGRectMake(cell.address.frame.size.width+cell.address.frame.origin.x, 59, WIDTH-148-cell.address.frame.size.width, 14);
    }else if (card_type_Id==99){
        
        NSDictionary *weatherDic=array[0];
        cell.heideImage.image=[UIImage imageNamed:@"TQ"];
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:FRAME(0, 9, 80, 80)];
        if (theFirst1-_secondDate>0)
        {
            NSString *imageUrl=[NSString stringWithFormat:@"%@",[weatherDic objectForKey:@"dayPictureUrl"]];
            [imgView setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:nil];
        }else{
            NSString *imageUrl=[NSString stringWithFormat:@"%@",[weatherDic objectForKey:@"nightPictureUrl"]];
            [imgView setImageWithURL:[NSURL URLWithString:imageUrl]placeholderImage:nil];
        }
        [cell.descriptionView addSubview:imgView];

//        cell.descriptionView.image=[UIImage imageNamed:@""];
        //[cell.descriptionView setContentMode:UIViewContentModeScaleAspectFit];
        
        UILabel *label=[[UILabel alloc]init];
        label.text=[NSString stringWithFormat:@"实时温度:%@",[dict objectForKey:@"real_temp"]];
        label.font=[UIFont fontWithName:@"Arial" size:13];
//        label.backgroundColor=[UIColor redColor];
        [label setNumberOfLines:1];
        [label sizeToFit];
        label.lineBreakMode=NSLineBreakByTruncatingTail;
        label.textColor=[UIColor colorWithRed:138/255.0f green:137/255.0f blue:137/255.0f alpha:1];
        label.frame=FRAME(129, 75, label.frame.size.width, 14);
        [cell addSubview:label];
        
        cell.sjLabel.text=@"温度:";
        [cell.sjLabel setNumberOfLines:1];
//        cell.sjLabel.backgroundColor=[UIColor redColor];
        [cell.sjLabel sizeToFit];
        cell.sjLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.sjLabel.frame=CGRectMake(129, 13+20, cell.sjLabel.frame.size.width, 14);
        
        cell.moneyLabel.text=@"风力:";
//        cell.moneyLabel.backgroundColor=[UIColor redColor];
        [cell.moneyLabel setNumberOfLines:1];
        [cell.moneyLabel sizeToFit];
        cell.moneyLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.moneyLabel.frame=CGRectMake(129, 36+20, cell.moneyLabel.frame.size.width, 14);
        
        cell.address.text=@"天气:";
        [cell.address setNumberOfLines:1];
        [cell.address sizeToFit];
        cell.address.lineBreakMode=NSLineBreakByTruncatingTail;
        cell.address.frame=CGRectMake(129, 59+20, cell.address.frame.size.width, 14);
        
        double inTime=[[dic objectForKey:@"service_time"] doubleValue];
        NSDateFormatter* inTimeformatter =[[NSDateFormatter alloc] init];
        inTimeformatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [inTimeformatter setDateStyle:NSDateFormatterMediumStyle];
        [inTimeformatter setTimeStyle:NSDateFormatterShortStyle];
        [inTimeformatter setDateFormat:@"YYYY年MM月dd日 HH:mm:ss"];
        NSDate* inTimedate = [NSDate dateWithTimeIntervalSince1970:inTime];
        NSString* inTimeString = [inTimeformatter stringFromDate:inTimedate];
        
        NSString *fromCityName=[NSString stringWithFormat:@"%@",[dic objectForKey:@"ticket_from_city_name"]];
        NSLog(@"出发%@",fromCityName);
        NSString *toCityName=[NSString stringWithFormat:@"%@",[weatherDic objectForKey:@"temperature"]];
        NSString *cityName=[NSString stringWithFormat:@"%@",toCityName];
        cell.inTimeLabel.text=[NSString stringWithFormat:@"%@",cityName];
        cell.inTimeLabel.frame=CGRectMake(cell.sjLabel.frame.size.width+cell.sjLabel.frame.origin.x, 13+20, WIDTH-148-cell.sjLabel.frame.size.width, 14);
        
        cell.costLabel.text=[NSString stringWithFormat:@"%@",[weatherDic objectForKey:@"wind"]];
        NSLog(@"%@",inTimeString);
        cell.costLabel.frame=CGRectMake(cell.moneyLabel.frame.size.width+cell.moneyLabel.frame.origin.x, 36+20, WIDTH-148-cell.moneyLabel.frame.size.width, 14);
        cell.addressLabel.text=[NSString stringWithFormat:@"%@",[weatherDic objectForKey:@"weather"]];
        cell.addressLabel.frame=CGRectMake(cell.address.frame.size.width+cell.address.frame.origin.x, 59+20, WIDTH-148-cell.address.frame.size.width, 14);
    }
    cell.zaButton.hidden=YES;
    cell.plButton.hidden=YES;
    cell.fxButton.hidden=YES;
    if (card_type_Id==99) {
        

        cell.contentLabel.text=[NSString stringWithFormat:@"%@",[textDic objectForKey:@"des"]];
        cell.praiseLabel.hidden=YES;
        cell.commentLabel.hidden=YES;
        for (int i=0; i<array.count-1; i++) {
            NSDictionary *dataDic=array[i+1];
            UIView *weatherView=[[UIView alloc]init];
            if (i==1) {
                weatherView.frame=FRAME((WIDTH/3+0.5)*i, cell.view.frame.size.height-40, WIDTH/3-1, 40);
            }else{
                weatherView.frame=FRAME((WIDTH/3+0.5)*i, cell.view.frame.size.height-40, WIDTH/3-0.5, 40);
            }
            weatherView.backgroundColor=[UIColor whiteColor];
            [cell addSubview:weatherView];
            
            UIView *view=[[UIView alloc]init];
            
            UILabel *dateLabel=[[UILabel alloc]init];
            dateLabel.text=[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"date"]];
            [dateLabel setNumberOfLines:1];
            [dateLabel sizeToFit];
            dateLabel.textColor=[UIColor colorWithRed:138/255.0f green:137/255.0f blue:137/255.0f alpha:1];
            dateLabel.textAlignment=NSTextAlignmentRight;
            dateLabel.font=[UIFont fontWithName:@"Arial" size:12];
            dateLabel.frame=FRAME(0, 27/2, dateLabel.frame.size.width, 13);
            [view addSubview:dateLabel];
            UIImageView *weathImage=[[UIImageView alloc]initWithFrame:FRAME(dateLabel.frame.size.width, 15, 10, 10)];
            if (theFirst1-_secondDate>0)
            {
                weathImage.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dataDic objectForKey:@"dayPictureUrl"]]]];
            }else{
                weathImage.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dataDic objectForKey:@"nightPictureUrl"]]]];
            }
            
            [view addSubview:weathImage];
            UILabel *celsiusLabel=[[UILabel alloc]init];
            celsiusLabel.text=[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"temperature"]];
            celsiusLabel.textColor=[UIColor colorWithRed:138/255.0f green:137/255.0f blue:137/255.0f alpha:1];
            [celsiusLabel setNumberOfLines:1];
            [celsiusLabel sizeToFit];
            celsiusLabel.textAlignment=NSTextAlignmentLeft;
            celsiusLabel.font=[UIFont fontWithName:@"Arial" size:12];
            celsiusLabel.frame=FRAME(dateLabel.frame.size.width+10, 27/2, celsiusLabel.frame.size.width, 13);
            [view addSubview:celsiusLabel];
            
            view.frame=FRAME((weatherView.frame.size.width-(dateLabel.frame.size.width+celsiusLabel.frame.size.width+10))/2, 0, dateLabel.frame.size.width+celsiusLabel.frame.size.width+10, 40);
            [weatherView addSubview:view];
        }
    }else{
        cell.contentLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"service_content"]];
        cell.praiseLabel.hidden=NO;
        cell.commentLabel.hidden=NO;
        cell.praiseLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"total_zan"]];
        cell.commentLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"total_comment"]];
        
        NSArray *array=@[@"common_icon_like_c@2x(1)",@"common_icon_review@2x(1)",@"common_icon_share@2x(1)"];
        UIButton *zaButton=[[UIButton alloc]initWithFrame:CGRectMake(0, cell.view.frame.size.height-40, WIDTH/3-0.5, 40)];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:FRAME((zaButton.frame.size.width-20)/2-5, 10, 20, 20)];
        imageView.image=[UIImage imageNamed:array[0]];
        [zaButton addSubview:imageView];
        [zaButton setTag:indexPath.row];
        [zaButton addTarget:self action:@selector(zaButtonan:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:zaButton];
        UIButton *plButton=[[UIButton alloc]initWithFrame:CGRectMake(WIDTH/3*1+0.5, cell.view.frame.size.height-40, WIDTH/3-1, 40)];
        UIImageView *plImageView=[[UIImageView alloc]initWithFrame:FRAME((plButton.frame.size.width-20)/2-5, 10, 20, 20)];
        plImageView.image=[UIImage imageNamed:array[1]];
        [plButton addSubview:plImageView];
        [plButton setTag:indexPath.row];
        [plButton addTarget:self action:@selector(plButtonan:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:plButton];
        UIButton *fxButton=[[UIButton alloc]initWithFrame:CGRectMake(WIDTH/3*2-0.5, cell.view.frame.size.height-40, WIDTH/3-0.5, 40)];
        UIImageView *fxImageView=[[UIImageView alloc]initWithFrame:FRAME((fxButton.frame.size.width-20)/2, 10, 20, 20)];
        fxImageView.image=[UIImage imageNamed:array[2]];
        [fxButton addSubview:fxImageView];
        [fxButton setTag:indexPath.row];
        [fxButton addTarget:self action:@selector(fxButtonan:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:fxButton];
    }
    for (int i=0; i<2; i++) {
        UIView *lineView=[[UIView alloc]initWithFrame:FRAME(WIDTH/3-0.5+WIDTH/3*i, cell.view.frame.size.height-30, 1, 20)];
        lineView.backgroundColor=[UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1];
        [cell addSubview:lineView];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PageTableViewCell *cell =[[PageTableViewCell alloc]init];
    return cell.view.frame.size.height;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int card_type_Id=[[numberArray[indexPath.row] objectForKey:@"card_type"]intValue];
    if (card_type_Id==99) {
        
    }else{
        NSString *card_ID=[numberArray[indexPath.row]objectForKey:@"card_id"];
        NSLog(@"card_id%@",card_ID);
        vc=[[DetailsViewController alloc]init];
        vc.card_ID=[card_ID intValue];
        vc.S=S;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(void)zaButtonan:(UIButton *)sender
{
    ISLoginManager *_manager = [ISLoginManager shareManager];
    //DownloadManager *_download = [[DownloadManager alloc]init];
    NSString *card_Id=[numberArray[sender.tag]objectForKey:@"card_id"];
    NSLog(@"ID%@",card_Id);
    _dict = @{@"card_id":card_Id,@"user_id":_manager.telephone};
    NSLog(@"字典数据%@",_dict);
    [_download requestWithUrl:CARD_DZ dict:_dict view:self.view delegate:self finishedSEL:@selector(logDowLoadDA:) isPost:YES failedSEL:@selector(DZDownFail:)];
    
}
-(void)logDowLoadDA:(id)sender
{
    NSLog(@"点赞成功");
    ISLoginManager *_manager = [ISLoginManager shareManager];
    _download = [[DownloadManager alloc]init];
    if ((lngString==nil&&latString==nil)||(lngString==NULL&&latString==NULL)) {
        lngString=@"";
        latString=@"";
    }
    _dict =@{@"service_date":timeString,@"user_id":_manager.telephone,@"card_from":@"0",@"page":@"1",@"lng":lngString,@"lat":latString};
    NSLog(@"字典数据%@",_dict);
    [_download requestWithUrl:CARD_LIST dict:_dict view:self.tableView delegate:self finishedSEL:@selector(logDowLoadFinish:) isPost:NO failedSEL:@selector(DownFail:)];
    
}
-(void)DZDownFail:(id)sender
{
    NSLog(@"点赞失败");
}

-(void)plButtonan:(UIButton *)sender
{
    NSString *card_ID=[numberArray[sender.tag]objectForKey:@"card_id"];
    NSLog(@"card_id%@",card_ID);
    vc=[[DetailsViewController alloc]init];
    vc.S=S;
    vc.card_ID=[card_ID intValue];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)fxButtonan:(UIButton *)sender
{
    [UMSocialSnsService presentSnsIconSheetView:self appKey:YMAPPKEY shareText:@"云行政，企业行政服务第一平台！极大降低企业行政管理成本，有效提升行政综合服务能力，快来试试吧！体验就送礼哦：http://51xingzheng.cn/h5-app-download.html" shareImage:[UIImage imageNamed:@"yunxingzheng-Logo-512.png"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,UMShareToSina,nil] delegate:self];
}


@end