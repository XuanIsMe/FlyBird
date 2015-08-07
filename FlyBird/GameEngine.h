//
//  GameEngine.h
//  FlyBird
//
//  Created by qianfeng on 14-9-23.
//  Copyright (c) 2014年 wangfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAmeAction : NSObject
@property (nonatomic, copy) void(^callBack)();
@property (nonatomic, assign) int timer;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isValid;
@end

@interface GameEngine : NSObject

+ (id)sharedEngine;
- (void)registerAction:(void(^)())block andTimer:(int)timer andName:(NSString *)name;
- (void)setValid:(BOOL)isvalid ForName:(NSString *)name;

- (void)gameOver;

- (void)restart;
@end
