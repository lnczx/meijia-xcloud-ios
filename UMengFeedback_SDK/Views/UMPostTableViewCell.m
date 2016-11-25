//
//  UMPostTableViewCell.m
//  Feedback
//
//  Created by amoblin on 14/9/10.
//  Copyright (c) 2014年 umeng. All rights reserved.
//

#import "UMPostTableViewCell.h"
#import "UMFeedback.h"
#import "UMOpenMacros.h"

@interface UMPostTableViewCell ()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *datelabel;

//@property (strong, nonatomic) UIImageView *statusImageView;

@end

@implementation UMPostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.playRecordButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
        [self.playRecordButton setBackgroundImage:[[UIImage imageNamed:@"bubble_min.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:10]
                               forState:UIControlStateNormal];
        [self.playRecordButton setImage:[UIImage imageNamed:@"umeng_fb_audio_play_default"] forState:UIControlStateNormal];
        [self.playRecordButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 70)];
//        [self.playRecordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [self.playRecordButton setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:self.playRecordButton];
        
        self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 5, 30, 30)];
        self.durationLabel.font = [UIFont systemFontOfSize:12.0];
        self.durationLabel.textColor = UM_UIColorFromRGB(100, 100, 100);
        [self addSubview:self.durationLabel];

        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = UM_UIColorFromHex(0xD8D8D8);
        self.lineView.autoresizingMask = 0x3f;
        //[self addSubview:self.lineView];
        
        self.label=[[UILabel alloc]init];
        self.label.numberOfLines = 0;
        self.label.font = [UIFont systemFontOfSize:14.0f];
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.label sizeToFit];
        [self  addSubview:self.label];
        
        self.datelabel=[[UILabel alloc]init];
        self.datelabel.font = [UIFont systemFontOfSize:11];
        self.datelabel.textColor = UM_UIColorFromHex(0x9B9B9B);
        [self addSubview:self.datelabel];
        
        self.iconImageView = [[UIImageView alloc] init];
        [self addSubview:self.iconImageView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
   // self.iconImageView.frame = CGRectMake(0, 0, 3, self.bounds.size.height);
    NSInteger scale = [UIScreen mainScreen].scale;
    self.lineView.frame = CGRectMake(0, self.bounds.size.height - 1.0/scale, self.bounds.size.width, 1.0/scale);
//    self.detailTextLabel.frame = CGRectMake(0, 0, 320, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)humanableInfoFromDate: (NSDate *) theDate {
    NSString *info;

    NSTimeInterval delta = - [theDate timeIntervalSinceNow];
    if (delta < 60) {
        // 1分钟之内
        info = UM_Local(@"Just now");
    } else {
        delta = delta / 60;
        if (delta < 60) {
            // n分钟前
            info = [NSString stringWithFormat:UM_Local(@"%d minutes ago"), (NSUInteger)delta];
        } else {
            delta = delta / 60;
            if (delta < 24) {
                // n小时前
                info = [NSString stringWithFormat:UM_Local(@"%d hours ago"), (NSUInteger)delta];
            } else {
                delta = delta / 24;
                if ((NSInteger)delta == 1) {
                    //昨天
                    info = UM_Local(@"Yesterday");
                } else if ((NSInteger)delta == 2) {
                    info = UM_Local(@"The day before yesterday");
                } else {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM-dd"];
                    info = [dateFormatter stringFromDate:theDate];
//                    info = [NSString stringWithFormat:@"%d天前", (NSUInteger)delta];
                }
            }
        }
    }
    return info;
}


- (void)configCell:(NSDictionary *)info {
    [_thumbImageButton setHidden:YES];
    int ID;
    if ([info[@"type"] isEqualToString:@"user_reply" ]) {
        // ME
        ID=10;
        //self.iconImageView.frame = CGRectMake(0, 0, 3, self.bounds.size.height);
        self.iconImageView.backgroundColor = UM_UIColorFromHex(0xDBDBDB);
    } else {
        // DEV
        ID=20;
        self.label.frame=CGRectMake(self.frame.size.width-self.textLabel.frame.size.width, 0, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        self.iconImageView.frame = CGRectMake(self.frame.size.width-3, 0, 3, self.bounds.size.height);
        self.iconImageView.backgroundColor = UM_UIColorFromHex(0x0FB0AA);
    }
    if (info[@"audio"]) {
        [self.playRecordButton setHidden:NO];
        [self.durationLabel setHidden:NO];
        [self setDuration:info[@"audio_length"]];
        if (UM_IOS_8_OR_LATER) {
            self.label.text = @"\n";
        } else {
            self.label.text = @"\n\n";
        }
    }
    else {
        [self.playRecordButton setHidden:YES];
        [self.durationLabel setHidden:YES];
        if (info[@"pic_id"])
        {
            UIImage *thumbImage = [[UMFeedback sharedInstance] thumbImageByID:info[@"pic_id"]];
            if (thumbImage)
            {
                if (!_thumbImageButton)
                {
                    self.thumbImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [self addSubview:_thumbImageButton];
                }
                [_thumbImageButton setHidden:NO];
                [_thumbImageButton setFrame:CGRectMake(13.f, 5.f, thumbImage.size.width, thumbImage.size.height)];
                [_thumbImageButton setImage:thumbImage forState:UIControlStateNormal];
                
            }
            self.label.text = UM_IOS_8_OR_LATER ? @"\n\n" : @"\n\n\n";
        }
        else
        {
            self.label.text = info[@"content"];
        }
    }
    if ([info[@"is_failed"] boolValue]) {
        self.label.textColor = UM_UIColorFromHex(0xff0000);
        self.datelabel.textColor = UM_UIColorFromHex(0xff0000);
    } else {
        self.label.textColor = UM_UIColorFromHex(0x000000);
        self.datelabel.textColor = UM_UIColorFromHex(0x000000);
    }
    self.label.numberOfLines = 0;
    self.label.font = [UIFont systemFontOfSize:14.0f];
    self.label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.label sizeToFit];
    if (ID==10) {
        self.iconImageView.frame=FRAME(5, 3, 40, 40);
        self.iconImageView.image=[UIImage imageNamed:@"家-我_默认头像"];
        self.label.frame=CGRectMake(self.iconImageView.frame.size.width+10, 5, self.bounds.size.width-(self.iconImageView.frame.size.width+10), self.label.frame.size.height);
        self.label.textAlignment=NSTextAlignmentLeft;
        self.datelabel.frame=CGRectMake(self.label.frame.origin.x, self.label.frame.size.height, 80, 20);
        self.datelabel.textAlignment=NSTextAlignmentLeft;
        
    }else if(ID==20){
        self.iconImageView.frame=FRAME(self.bounds.size.width-45, 3, 40, 40);
        self.iconImageView.image=[UIImage imageNamed:@"bolohr-logo512.png"];
        self.label.frame=CGRectMake(0, 5, self.bounds.size.width-(self.iconImageView.frame.size.width+10), self.label.frame.size.height);
        self.datelabel.frame=CGRectMake(self.bounds.size.width-130, self.label.frame.size.height, 80, 20);
        self.label.textAlignment=NSTextAlignmentRight;
        self.datelabel.textAlignment=NSTextAlignmentRight;
    }
    self.iconImageView.layer.cornerRadius=self.iconImageView.frame.size.width/2;
    self.iconImageView.clipsToBounds = YES;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[info[@"created_at"] doubleValue] / 1000];
    self.datelabel.text = [self humanableInfoFromDate:date];
}

- (void)setDuration:(NSNumber *)duration {
    self.durationLabel.text = [NSString stringWithFormat:@"%ld\"", (long)duration.integerValue];
}

@end
