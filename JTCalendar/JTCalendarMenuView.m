//
//  JTCalendarMenuView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMenuView.h"

#import "JTCalendar.h"
#import "JTCalendarMenuMonthView.h"

#define NUMBER_PAGES_LOADED 1 // Must be the same in JTCalendarView, JTCalendarMenuView, JTCalendarContentView

@interface JTCalendarMenuView(){
    NSMutableArray *monthsViews;
}

@end

@implementation JTCalendarMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    monthsViews = [NSMutableArray new];
    
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.clipsToBounds = YES;
    
    for(int i = 0; i < NUMBER_PAGES_LOADED+2; ++i){
        JTCalendarMenuMonthView *monthView = [JTCalendarMenuMonthView new];
        monthView.alpha=1;
//        if (i!=1) {
//            monthView.alpha=0.0;
//        }else{
//            [UIView beginAnimations:nil context:nil];
//            //设置动画时长
//            [UIView setAnimationDuration:1];
//            monthView.alpha=1;
//            [UIView commitAnimations];
//        }
        [self addSubview:monthView];
        [monthsViews addObject:monthView];
    }
}

- (void)layoutSubviews
{
    [self configureConstraintsForSubviews];
        
    [super layoutSubviews];
}

- (void)configureConstraintsForSubviews
{
    self.contentOffset = CGPointMake(self.contentOffset.x, 0); // Prevent bug when contentOffset.y is negative
    
    CGFloat x = 0;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if(self.calendarManager.calendarAppearance.ratioContentMenu != 1.){
        width = self.frame.size.width / self.calendarManager.calendarAppearance.ratioContentMenu;
        x = 0;
    }
    
    if(self.calendarManager.calendarAppearance.readFromRightToLeft){
        for(UIView *view in [[monthsViews reverseObjectEnumerator] allObjects]){
            view.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(view.frame);
        }
    }
    else{
        for(UIView *view in monthsViews){
            view.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(view.frame);
        }
    }
    
    self.contentSize = CGSizeMake(width * NUMBER_PAGES_LOADED, height);
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    self->_currentDate = currentDate;
 
    NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
    NSDateComponents *dayComponent = [NSDateComponents new];
    
    for(int i = 0; i < NUMBER_PAGES_LOADED; ++i){
        JTCalendarMenuMonthView *monthView = monthsViews[1];
//        if (i==1) {
//            [UIView beginAnimations:nil context:nil];
//            //设置动画时长
//            [UIView setAnimationDuration:5];
        for (int s=0; s<3; s++) {
            monthView.alpha=1;
        }
        
//            [UIView commitAnimations];

//        }
        dayComponent.month = 1- (3 / 2);
        NSDate *monthDate = [calendar dateByAddingComponents:dayComponent toDate:self.currentDate options:0];
        
        NSDateFormatter  *yerformatter=[[NSDateFormatter alloc] init];
        [yerformatter setDateFormat:@"yyyy"];
        NSString *  yearStr=[yerformatter stringFromDate:monthDate];
        
        NSDateFormatter  *monthformatter=[[NSDateFormatter alloc] init];
        [monthformatter setDateFormat:@"MM"];
        NSString *motStr=[monthformatter stringFromDate:monthDate];
//        int mot=[motStr intValue]-1;
//        NSString *  monthStr;
//        if (mot<10) {
//            if (mot<0) {
//                monthStr=[NSString stringWithFormat:@"12"];
//            }else{
//                monthStr=[NSString stringWithFormat:@"0%d",mot];
//            }
//        }else{
//            monthStr=[NSString stringWithFormat:@"0%d",mot];
//        }
        
        
        ISLoginManager *_manager = [ISLoginManager shareManager];
        DownloadManager *download = [[DownloadManager alloc]init];
        NSDictionary *dict=@{@"user_id":_manager.telephone,@"year":yearStr,@"month":motStr};
        UIView *view=[[UIView alloc]init];
        [download requestWithUrl:@"simi/app/user/msg/total_by_month.json"  dict:dict view:view delegate:self finishedSEL:@selector(RiLiSuccess:) isPost:NO failedSEL:@selector(RiLiFailure:)];
        [monthView setCurrentDate:monthDate];
    }
    
}
-(void)RiLiSuccess:(id)sender
{
    NSArray *array=[sender objectForKey:@"data"];
    AppDelegate *delegates=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    for (int i=0; i<array.count; i++) {
        if([delegates.riliArray containsObject:array[i]])
        {
            
        }else{
            [delegates.riliArray addObject:array[i]];
        }
    }
    
//    delegates.riliArray=array;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RILIARRAY" object:nil];
}
-(void)RiLiFailure:(id)sender
{
    NSLog(@"日历布局失败返回:%@",sender);
}

#pragma mark - JTCalendarManager

- (void)setCalendarManager:(JTCalendar *)calendarManager
{
    self->_calendarManager = calendarManager;
    
    for(JTCalendarMenuMonthView *view in monthsViews){
        [view setCalendarManager:calendarManager];
    }
}

- (void)reloadAppearance
{
    self.scrollEnabled = !self.calendarManager.calendarAppearance.isWeekMode;
    
    [self configureConstraintsForSubviews];
    for(JTCalendarMenuMonthView *view in monthsViews){
        [view reloadAppearance];
    }
}

@end
