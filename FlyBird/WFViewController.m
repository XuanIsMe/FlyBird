//
//  WFViewController.m
//  FlyBird
//
//  Created by qianfeng on 14-9-23.
//  Copyright (c) 2014年 wangfei. All rights reserved.
//

#import "WFViewController.h"
#define UISCREEN_SIZE [UIScreen mainScreen].bounds.size
@interface WFViewController ()
{
    UIImageView *_planeView;
    UIScrollView *_birdView;
    NSMutableArray *_wallArray;
    UIButton *_restartButton;
}

@end

@implementation WFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //hello
    self.view.backgroundColor = [UIColor colorWithRed:0.44f green:0.63f blue:0.96f alpha:1.00f];
    _wallArray = [[NSMutableArray alloc] init];
    [self uiConfig];
    [self actionConfig];
    NSLog(@"%@", [UIFont familyNames]);
    
}

- (void)uiConfig{
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
    _planeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plane1"]];
    _planeView.center = CGPointMake(400, 100);
    [self.view addSubview:_planeView];
    
    _birdView = [[UIScrollView alloc] initWithFrame:CGRectMake(142, 200, 36, 24)];
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flappy_fly"]];
    [_birdView addSubview:imgV];
    [self.view addSubview:_birdView];
    
    _restartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _restartButton.backgroundColor = [UIColor whiteColor];
    _restartButton.frame = CGRectMake(80, 200, 160, 100);
    _restartButton.titleLabel.numberOfLines = 2;
    [_restartButton setTitle:@"GAME OVER\n  再玩一次" forState:UIControlStateNormal];
    _restartButton.titleLabel.font = [UIFont fontWithName:@"yuweij" size:25];
    [_restartButton addTarget:self action:@selector(restartAction) forControlEvents:UIControlEventTouchUpInside];
    _restartButton.hidden = YES;
    
    [self.view addSubview:_restartButton];
}


- (void)actionConfig{
    [[GameEngine sharedEngine] registerAction:^{
        _planeView.center = CGPointMake(_planeView.center.x-2, _planeView.center.y);
    } andTimer:1 andName:@"planeMove"];
    
    [[GameEngine sharedEngine] registerAction:^{
        if (_planeView.center.x + _planeView.frame.size.width/2 < 0) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"plane%d", (arc4random()%11) + 1]];
            _planeView.image = img;
            _planeView.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
            _planeView.center = CGPointMake(420 + img.size.width/2, 50+(arc4random()%20));
        }
    } andTimer:10 andName:@"planeChange"];
    
    [[GameEngine sharedEngine] registerAction:^{
        CGFloat newx = _birdView.contentOffset.x + 36;
        _birdView.contentOffset = CGPointMake(newx > 216?0:newx, 0);
    } andTimer:3 andName:@"birdFly"];
    
    [[GameEngine sharedEngine] registerAction:^{
            _birdView.center = CGPointMake(_birdView.center.x, _birdView.center.y + speed);
            speed += 1;
            _birdView.transform = CGAffineTransformMakeRotation(M_PI/180*(speed>=0?10:-10));
    } andTimer:3 andName:@"birdMove"];
    
    [[GameEngine sharedEngine] setValid:NO ForName:@"birdMove"];
    
    [[GameEngine sharedEngine] registerAction:^{
        // 遍历数组并且要删除元素的时候，从后往前遍历
        for (int i = _wallArray.count-1; i >= 0 ; i--) {
            UIImageView *wall = _wallArray[i];
            wall.center = CGPointMake(wall.center.x - 1.1, wall.center.y);
            if (wall.center.x < -52) {
                [wall removeFromSuperview];
                [_wallArray removeObject:wall];
            }
        }
        if ([[_wallArray lastObject] center].x < 160 || _wallArray.count == 0) {
            [self creatWalls];
        }
    } andTimer:1 andName:@"wallsMove"];
    [[GameEngine sharedEngine] setValid:NO ForName:@"wallsMove"];
    
    [[GameEngine sharedEngine] registerAction:^{
        for (UIImageView *wall in _wallArray) {
            if (CGRectIntersectsRect(wall.frame, _birdView.frame)) {
                [self gameOver];
            }
        }
        if (_birdView.center.y >= UISCREEN_SIZE.height - (_birdView.bounds.size.height/2)) {
            [self gameOver];
        }
    } andTimer:1 andName:@"check"];
}

- (void)gameOver{
    [[GameEngine sharedEngine] gameOver];
    _restartButton.hidden = NO;
    [self.view bringSubviewToFront:_restartButton];
}

- (void)restartAction{
    speed = 0;
    // 隐藏按钮
    _restartButton.hidden = YES;
    // 重启游戏
    [[GameEngine sharedEngine] restart];
    // 删除柱子
    for (UIImageView *im in _wallArray) {
        [im removeFromSuperview];
    }
    [_wallArray removeAllObjects];
    _birdView.center = CGPointMake(80, 200);
}

- (void)creatWalls{
    UIImageView *topWall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_wall"]];
    UIImageView *bottomWall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_wall"]];
    
    int ran = arc4random() % 290;
    topWall.center = CGPointMake(350, -(500/2)+50 + ran);
    bottomWall.center = CGPointMake(topWall.center.x, topWall.center.y + 90 + 500);
    
    [_wallArray addObject:topWall];
    [_wallArray addObject:bottomWall];
    
    [self.view addSubview:topWall];
    [self.view addSubview:bottomWall];
}

static CGFloat speed = 0;

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [[GameEngine sharedEngine]setValid:YES ForName:@"birdMove"];
//}

- (void)tapAction {
    [[GameEngine sharedEngine] setValid:YES ForName:@"birdMove"];
    if (_birdView.center.y >= 5 + _birdView.bounds.size.height/2) {
        speed = -8;
    } else {
        speed = 0;
    }
    [[GameEngine sharedEngine] setValid:YES ForName:@"wallsMove"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
