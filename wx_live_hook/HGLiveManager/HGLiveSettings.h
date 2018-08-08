//
//  HGLiveSettings.h
//  wxLiveDylib
//
//  Created by jyh on 2018/8/5.
//  Copyright © 2018年 huig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGLiveHook.h"

@interface HGLiveSettings : NSObject
+ (instancetype)shared;
+ (void)setupServer:(NSString *)address room:(NSString *)room;
+ (void)DelMsg:(NSString *)DelMsg MsgWrap:(CMessageWrap *)MsgWrap;
+ (void)AddMsg:(NSString *)AddMsg MsgWrap:(CMessageWrap *)MsgWrap;
+ (void)AddMsgWithContent:(NSString *)nsContent;
+ (BOOL)isNoAddress;
+ (NSString *)getPlayAddress;
+ (BOOL)isEqualToCommand:(NSString *)command;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, strong) CMessageMgr *mgr;
@property (nonatomic, strong) CMessageWrap *wrap;
@end
