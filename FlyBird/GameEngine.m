//
//  GameEngine.m
//  FlyBird
//
//  Created by qianfeng on 14-9-23.
//  Copyright (c) 2014年 wangfei. All rights reserved.
//

#import "GameEngine.h"

@implementation GAmeAction



@end

@implementation GameEngine
{
    NSTimer *_timer;
    NSMutableArray *_actionArray;
}

+ (id)sharedEngine{
    static GameEngine *_e = nil;
    if (!_e) {
        _e = [[GameEngine alloc] init];
    }
    return _e;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        _actionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

static int count = 0;
- (void)timerAction{
    count++;
    for (GAmeAction *a in _actionArray) {
        if (a.isValid && count%a.timer == 0) {
            // 用
            a.callBack();
        }
    }
}

- (void)registerAction:(void(^)())block andTimer:(int)timer andName:(NSString *)name{
    GAmeAction *action = [[GAmeAction alloc] init];
    action.callBack = block;
    action.timer = timer;
    action.name = name;
    action.isValid = YES;
    [_actionArray addObject:action];
}

- (void)setValid:(BOOL)isvalid ForName:(NSString *)name{
    for (GAmeAction *a in _actionArray) {
        if ([a.name isEqualToString:name]) {
            a.isValid = isvalid;
        }
    }
}

- (void)gameOver{
//    [_timer setFireDate:[NSDate distantFuture]];
    for (GAmeAction *a in _actionArray) {
        if (![a.name isEqualToString:@"planeMove"] && ![a.name isEqualToString:@"planeChange"]) {
            [self setValid:NO ForName:a.name];
        }
    }
}

- (void)restart{
//   [_timer setFireDate:[NSDate distantPast]];
    for (GAmeAction *a in _actionArray) {
        if (![a.name isEqualToString:@"planeMove"] && ![a.name isEqualToString:@"planeChange"]) {
            [self setValid:YES ForName:a.name];
        }
    }
}

@end
