//
//  NewsViewController.m
//  网易新闻
//
//  Created by monica on 16/8/3.
//  Copyright © 2016年 xyx. All rights reserved.
//

#import "NewsViewController.h"
#import "TopViewController.h"
#import "HotViewController.h"
#import "VedioViewController.h"
#import "SocialViewController.h"
#import "ReadViewController.h"
#import "TechViewController.h"

static int const labelWidth  = 100;
static CGFloat const radio = 1.3;


#define Width  [UIScreen mainScreen].bounds.size.width
#define Height  [UIScreen mainScreen].bounds.size.height

@interface NewsViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *titleScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak ,nonatomic) UILabel *selLabel;
@property (strong,nonatomic)NSMutableArray *titleLabels;

@end

@implementation NewsViewController

-(NSMutableArray *)titleLabels{
    
    if (_titleLabels == nil) {
        
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupChildVC];
    [self setupTitleView];
    
    //初始化UIscrollview
    [self setupUIscrollView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;


}

-(void)setupUIscrollView{
    
    NSUInteger count = self.childViewControllers.count;

    
    self.titleScrollView.contentSize = CGSizeMake(count*labelWidth, 0);
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    
    self.contentScrollView.contentSize = CGSizeMake(count *Width, 0);
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = YES;
    
    self.contentScrollView.delegate = self;

    
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat curPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    // 左边label角标
    NSInteger leftIndex = curPage;
    // 右边的label角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 获取左边的label
    UILabel *leftLabel = self.titleLabels[leftIndex];
    
    // 获取右边的label
    UILabel *rightLabel;
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    
    // 计算下右边缩放比例
    CGFloat rightScale = curPage - leftIndex;
    
    // 计算下左边缩放比例
    CGFloat leftScale = 1 - rightScale;
    
    // 0 ~ 1
    // 1 ~ 2
    // 左边缩放
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3+ 1);
    
    // 右边缩放
    rightLabel.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 1, rightScale * 0.3+ 1);
    
    NSLog(@"%f",curPage);
    
    leftLabel.textColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    rightLabel.textColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];

    
}

#pragma mark - UIScrollVeiwDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    
    [self showVC:index];
    
    
    //选中对应标题
    UILabel *selLabel = self.titleLabels[index];
    [self selectLabel:selLabel];
    
    //让选中的标题居中
    [self setupTitleCenter:selLabel];
    
}

-(void)showVC:(NSInteger)index{
    
    UIViewController *vc = self.childViewControllers[index];
    
    CGFloat offsetX = index * Width;
    
    if (vc.isViewLoaded) return ;
    vc.view.frame = CGRectMake(offsetX, 0, Width, Height);
    
    [self.contentScrollView addSubview:vc.view];

}

-(void)setupTitleCenter:(UILabel*)centerLabel{
    
    CGFloat offsetX = centerLabel.center.x - Width*0.5;
   
    
    if (offsetX<0) {
        offsetX = 0;
    }
    
   CGFloat maxoffsetX = self.titleScrollView.contentSize.width - Width;
    if (offsetX>maxoffsetX) {
        
        offsetX = maxoffsetX;
    }
    
     [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}



//添加子控制器标题
-(void)setupTitleView{
    
    NSUInteger count = self.childViewControllers.count;
    
    CGFloat lableX = 0;
    CGFloat lableY = 0;
    CGFloat lableHeight = 44;
    
    for (int i=0; i<count; i++) {
        
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor yellowColor];
        
        UIViewController *vc = self.childViewControllers[i];
        
        lableX = i*labelWidth;
        label.frame = CGRectMake(lableX, lableY, labelWidth, lableHeight);
        label.text = vc.title;
        label.highlightedTextColor = [UIColor redColor];
        label.tag = i;
        label.userInteractionEnabled = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [self.titleLabels addObject:label];

        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(titleClick:)];
        
        [label addGestureRecognizer:tap];
        
        if (i==0) {
            
            [self titleClick:tap];
        }
        
        
        [self.titleScrollView addSubview:label];
        
    }
    
    
}

-(void)titleClick:(UIGestureRecognizer *)tap{
       //label变成红色
    
    UILabel *selLabel = (UILabel *)tap.view;
    [self selectLabel:selLabel];
    NSInteger index = selLabel.tag;
    
    //滚动到指定位置
    CGFloat offsetX = selLabel.tag * Width;
    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0);
    
    //将子控制器添加
    [self showVC:index];
    
    [self setupTitleCenter:selLabel];
}

-(void)selectLabel:(UILabel *)label{
    //获取选中的label
    _selLabel.highlighted = NO;
    // 取消形变
    _selLabel.transform = CGAffineTransformIdentity;
    //取消颜色
    _selLabel.textColor = [UIColor blackColor];
    
    label.highlighted = YES;
    _selLabel = label;
    label.transform = CGAffineTransformMakeScale(radio, radio);


    
}

//添加子控制器
-(void)setupChildVC{
   
    TopViewController *top = [[TopViewController alloc]init];
    top.title = @"头条";
    [self addChildViewController:top];
    
    HotViewController *hot = [[HotViewController alloc]init];
    hot.title = @"热点";
    [self addChildViewController:hot];
    
    VedioViewController *vedio = [[VedioViewController alloc]init];
    vedio.title = @"视频";
    [self addChildViewController:vedio];
    
    SocialViewController *social = [[SocialViewController alloc]init];
    social.title = @"社会";
    [self addChildViewController:social];
    
    ReadViewController *read = [[ReadViewController alloc]init];
    read.title = @"阅览";
    [self addChildViewController:read];

    TechViewController *tech = [[TechViewController alloc]init];
    tech.title = @"科技";
    [self addChildViewController:tech];

    
    
    
}
@end
