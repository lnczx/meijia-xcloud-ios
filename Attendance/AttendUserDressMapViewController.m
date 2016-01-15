 //
//  AttendUserDressMapViewController.m
//  yxz
//
//  Created by 白玉林 on 16/1/14.
//  Copyright © 2016年 zhirunjia.com. All rights reserved.
//

#import "AttendUserDressMapViewController.h"
#import "BMKMapView.h"
#import "BMKPoiSearch.h"
#import "MapTableViewCell.h"
#import "UserAddressMapModel.h"
#import "BMKPointAnnotation.h"
#import "BMKPinAnnotationView.h"
#import "BMKLocationService.h"
#import "DownloadManager.h"
#import "ISLoginManager.h"
#import "MBProgressHUD+Add.h"
@interface AttendUserDressMapViewController ()<UITextFieldDelegate,BMKPoiSearchDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField *myTextField;
    BMKPoiSearch *_searcher;
    UITableView *_myTableView;
    NSMutableArray *_busPoiArray;
    NSMutableArray *_zhoubianArray;
    BMKMapView* _mapView;
    BMKLocationService *_locService;
    NSMutableArray *dataArray;
    BMKPointAnnotation* annoTation;//大头针
    CGFloat headHeight;
    UserAddressMapModel *mapModel;
    int cellIDS;
    NSString *lngString;
    NSString *latString;
}


@end

@implementation AttendUserDressMapViewController

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cellIDS=-1;
    self.navlabel.text = @"添加地址";
    
    self.navigationController.navigationBarHidden = YES;
    _busPoiArray = [[NSMutableArray alloc]init];
    _zhoubianArray = [[NSMutableArray alloc]init];
    dataArray = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 100, SELF_VIEW_WIDTH, 200)];
    [self.view addSubview:_mapView];
#warning 定位
    
    NSLog(@"进入普通定位态");
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    
    myTextField = [[UITextField alloc]initWithFrame:FRAME(40, 64, SELF_VIEW_WIDTH-40, 36)];
    myTextField.delegate = self;
    myTextField.tag = 99;
    myTextField.backgroundColor = HEX_TO_UICOLOR(BAC_VIEW_COLOR, 1.0);
    myTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    myTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:myTextField];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:FRAME(10, 70, 20, 20)];
    img.image = [UIImage imageNamed:@"order-addr"];
    [self.view addSubview:img];
    
#warning 初始化检索对象
    //初始化检索对象
    _searcher =[[BMKPoiSearch alloc]init];
    _searcher.delegate = self;
    _myTableView = [[UITableView alloc]initWithFrame:FRAME(0, myTextField.bottom, SELF_VIEW_WIDTH, SELF_VIEW_HEIGHT-myTextField.bottom-40)];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.hidden = YES;
    [self.view addSubview:_myTableView];
    
    
    UIButton *disBtn = [[UIButton alloc]initWithFrame:FRAME(0, HEIGHT-40, WIDTH, 40)];
    [disBtn setTitle:@"确定" forState:UIControlStateNormal];
    disBtn.backgroundColor=[UIColor colorWithRed:232/255.0f green:55/255.0f blue:74/255.0f alpha:1];
    disBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [disBtn addTarget:self action:@selector(addDress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:disBtn];
    
    
    // Do any additional setup after loading the view.
}
- (void)addDress
{
    
    
    if (myTextField.text.length == 0 || _myTableView.top == myTextField.bottom) {
        [MBProgressHUD showError:@"请选择地址!" toView:self.view];
        return;
    }
    ISLoginManager *_manager = [ISLoginManager shareManager];
    
    NSDictionary *_dict = @{@"user_id":_manager.telephone,
                            @"company_id":_company_id,
                            @"poi_name":myTextField.text,
                            @"poi_lat":latString,
                            @"poi_lng":lngString,
                            @"checkin_type":@"0",
                            /*@"checkin_net":mapModel.name,
                            @"remarks":mapModel.address,*/
                            };
    
    DownloadManager *_download = [[DownloadManager alloc]init];
    [_download requestWithUrl:[NSString stringWithFormat:@"%@",ATTEND_CHECKIN] dict:_dict view:self.view delegate:self finishedSEL:@selector(addDressSuccess:) isPost:YES failedSEL:@selector(addDressFail:)];
    
}
-(void)todoSomething
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addDressSuccess:(id)dict
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething) object:nil];
    [self performSelector:@selector(todoSomething) withObject:nil afterDelay:0.2f];

}
- (void)addDressFail:(id)error
{
    NSLog(@"error: %@",error);
}

- (void)ResignFirstResponder
{
    [myTextField resignFirstResponder];
}

- (void) textFieldChange:(NSNotification *)notification
{
    
#warning 城市检索
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = 0;
    citySearchOption.pageCapacity = 10;
    citySearchOption.city= @"北京";
    UITextField *textfield = (UITextField *) [self.view viewWithTag:99];
    citySearchOption.keyword = textfield.text;
    BOOL flag = [_searcher poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
    if (textfield.text.length == 0) {
        [_busPoiArray removeAllObjects];
        dataArray = _zhoubianArray;
        _myTableView.frame = FRAME(0, _mapView.bottom, SELF_VIEW_WIDTH, SELF_VIEW_HEIGHT-_mapView.bottom-40);
        headHeight = 22.0;
        [_myTableView reloadData];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //    NSLog(@"搜索:%@",textField.text);
    [myTextField resignFirstResponder];
    return YES;
}
//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"搜索正常:搜索结果数量：%i,%@",poiResultList.totalPoiNum,poiResultList.poiInfoList);
        //        [dataArray removeAllObjects];
        [_busPoiArray removeAllObjects];
        BMKPoiInfo* poi = nil;
        BOOL findBusline = NO;
        if (_zhoubianArray.count == 0) {           //附近地点
            headHeight = 22.0;
            for (int i = 0; i < poiResultList.poiInfoList.count; i++) {
                poi = [poiResultList.poiInfoList objectAtIndex:i];
                NSLog(@"poi.epoitype:%i",poi.epoitype);
                if (poi.epoitype == 0) {
                    findBusline = YES;
                    [_zhoubianArray addObject:poi];
                    
                    [_myTableView reloadData];
                    _myTableView.frame = FRAME(0, _mapView.bottom, SELF_VIEW_WIDTH, SELF_VIEW_HEIGHT-_mapView.bottom-40);
                    //                    _myTableView.hidden = (_busPoiArray.count > 0)?  NO : YES;
                    _myTableView.hidden = NO;
                    dataArray = _zhoubianArray;
                }
            }
        }else{
            headHeight = 0.0;
            //            [dataArray removeAllObjects];
            for (int i = 0; i < poiResultList.poiInfoList.count; i++) {
                poi = [poiResultList.poiInfoList objectAtIndex:i];
                NSLog(@"poi.epoitype:%i",poi.epoitype);
                if (poi.epoitype == 0) {
                    findBusline = YES;
                    [_busPoiArray addObject:poi];
                    
                    [_myTableView reloadData];
                    _myTableView.frame = FRAME(0, myTextField.bottom, SELF_VIEW_WIDTH, SELF_VIEW_HEIGHT-myTextField.bottom-40);
                    _myTableView.hidden = (_busPoiArray.count > 0)?  NO : YES;
                    dataArray = _busPoiArray;
                }
            }
            [_myTableView reloadData];
            
        }
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
        UITextField *textfield = (UITextField *) [self.view viewWithTag:22];
        textfield.text = @"";
        textfield.frame = FRAME(40, 60, SELF_VIEW_WIDTH-40, 40);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 00.0;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *TableSampleIdentifier = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    MapTableViewCell *Cell = [tableView cellForRowAtIndexPath:indexPath];
    if (Cell == nil) {
        Cell = [[MapTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    }
    
    UserAddressMapModel *mapmodel = [[UserAddressMapModel alloc]initWithArray:dataArray index:indexPath.row];
    Cell.mymodel = mapmodel;
    if (cellIDS==indexPath.row) {
        [Cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    return Cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    cellIDS=(int)indexPath.row;
    mapModel = [[UserAddressMapModel alloc]initWithArray:dataArray index:indexPath.row];
    
    double weidu = mapModel.latitude;
    double jingdu = mapModel.longitude;
    
    //添加大头针
    if (annoTation != nil) {   //移除之前的大头针
        [_mapView removeAnnotation:annoTation];
    }
    
    annoTation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = weidu;
    coor.longitude = jingdu;
    annoTation.coordinate = coor;
    annoTation.title = mapModel.name;
    [_mapView addAnnotation:annoTation];
    
    myTextField.text = mapModel.name;
    //    _myTableView.hidden = YES;
    [myTextField resignFirstResponder];
    
#warning 显示指定位置坐标
    BMKCoordinateRegion region ;//表示范围的结构体
    CLLocationCoordinate2D a = CLLocationCoordinate2DMake(weidu, jingdu);
    region.center = a;//中心点
    lngString=[NSString stringWithFormat:@"%f",a.longitude];
    latString=[NSString stringWithFormat:@"%f",a.latitude];
    region.span.latitudeDelta = 0.05;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.05;//纬度范围
    [_mapView setRegion:region animated:YES];
    
    headHeight = 22.0;
    dataArray = _zhoubianArray;
    [_myTableView reloadData];
    _myTableView.hidden = NO;
    _myTableView.frame = FRAME(0, _mapView.bottom, SELF_VIEW_WIDTH, SELF_VIEW_HEIGHT-_mapView.bottom-40);
    
    [_myTableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 22)];
    
    footerView.backgroundColor = HEX_TO_UICOLOR(BAC_VIEW_COLOR, 1.0);
    
    footerView.autoresizesSubviews = YES;     //重载子视图的位置
    
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth; //控件的宽度随着父视图的宽度按比例改变；
    
    footerView.userInteractionEnabled = YES;
    
    footerView.hidden = NO;
    
    footerView.multipleTouchEnabled = YES;
    
    footerView.opaque = NO;  //不透明
    
    footerView.contentMode = UIViewContentModeScaleToFill;
    
    footerView.tag = section;
    
    
    UILabel *lable = [[UILabel alloc]initWithFrame:FRAME(10, 0, footerView.width-20, footerView.height)];
    lable.text = @"附近地点";
    lable.textColor = [UIColor blackColor];
    lable.font = [UIFont systemFontOfSize:12];
    [footerView addSubview:lable];
    
    return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton *btn = [[UIButton alloc]initWithFrame:FRAME(0, 0, SELF_VIEW_WIDTH, 30)];
    [btn setTitle:@"点击加载更多" forState:UIControlStateNormal];
    btn.backgroundColor = HEX_TO_UICOLOR(BAC_VIEW_COLOR, 1.0);
    
    return btn;
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        
        //        [_mapView updateLocationData:userLocation];
        
        return newAnnotationView;
    }
    return nil;
}
- (void)willStartLocatingUser
{
    NSLog(@"即将定位");
}
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}
//定位成功后走这里
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"开始定位，坐标是%@",userLocation.heading);
    NSLog(@"开始定位，地址是%@,title:%@subtitle:%@head:%@",userLocation.location,userLocation.title,userLocation.subtitle,userLocation.heading);
    
    _mapView.showsUserLocation = YES;//显示定位图层
    [_mapView updateLocationData:userLocation];
    [_locService stopUserLocationService];
    
#warning 显示指定位置坐标
    BMKCoordinateRegion region ;//表示范围的结构体
    CLLocationCoordinate2D a = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    region.center = a;//中心点
    //   NSLog(@"%@",a);
    region.span.latitudeDelta = 0.1;//经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    region.span.longitudeDelta = 0.2;//纬度范围
    [_mapView setRegion:region animated:YES];
    
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 0;
    option.pageCapacity = 10;
    option.location = a;
    option.location = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    option.radius = 1000;  //检索半径
    option.keyword = @"写字楼";
    BOOL flag = [_searcher poiSearchNearBy:option];
    
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        NSLog(@"周边检索发送失败");
    }
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}
- (void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"定位失败");
    NSLog(@"error: %@",error);
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