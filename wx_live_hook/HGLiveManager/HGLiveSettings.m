//
//  HGLiveSettings.m
//  wxLiveDylib
//
//  Created by jyh on 2018/8/5.
//  Copyright © 2018年 huig. All rights reserved.
//

#import "HGLiveSettings.h"
#import "HGLiveHook.h"
#import <objc/runtime.h>

@interface HGLiveSettings()

@end
@implementation HGLiveSettings

static HGLiveSettings *_shareInstance = nil;
+ (instancetype)shared {
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

- (void)setWrap:(CMessageWrap *)wrap {
    _wrap = [wrap copy];
    _wrap.m_nsFromUsr = wrap.m_nsToUsr;
    _wrap.m_nsToUsr = wrap.m_nsFromUsr;
    _wrap.m_uiMesLocalID = 0;
    _wrap.m_n64MesSvrID = 0;
    _wrap.m_uiStatus = 1;
    _wrap.m_uiMessageType = 1;
    _wrap.m_nsMsgSource = nil;
}

+ (void)setupServer:(NSString *)address room:(NSString *)room {
    NSString *fwq = [address stringByReplacingOccurrencesOfString:@":" withString:@""];
    fwq = [fwq stringByReplacingOccurrencesOfString:@"：" withString:@""];
    fwq = [fwq stringByReplacingOccurrencesOfString:@" " withString:@""];
    fwq = [fwq stringByReplacingOccurrencesOfString:@"#服务器" withString:@""];
    if (fwq.length < 8) return;
    NSString *roomID = [room stringByReplacingOccurrencesOfString:@"wxid_" withString:@""];
    NSString *rtmpAddress = [NSString stringWithFormat:@"rtmp://%@:2018/hls/%@",fwq ,roomID];
    NSString *httpAddress = [NSString stringWithFormat:@"http://%@:8080/hls/%@.m3u8",fwq, roomID];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:rtmpAddress forKey:@"rtmpAddress"];
    [ud setObject:httpAddress forKey:@"httpAddress"];
    [ud synchronize]; //立即写入
}

+ (void)DelMsg:(NSString *)DelMsg MsgWrap:(CMessageWrap *)MsgWrap {
    [[[self shared] mgr] DelMsg:DelMsg MsgWrap:MsgWrap];
    [[[self shared] mgr] DelMsg:DelMsg MsgList:MsgWrap DelAll:NO];
    [[[self shared] mgr] AsyncOnDelMsg:DelMsg MsgWrap:MsgWrap];
}

+ (void)AddMsg:(NSString *)AddMsg MsgWrap:(CMessageWrap *)MsgWrap {
    [[[self shared] mgr] AddMsg:AddMsg MsgWrap:MsgWrap];
    [self DelMsg:AddMsg MsgWrap:MsgWrap];
}

+ (void)AddMsgWithContent:(NSString *)nsContent {
    CMessageWrap *MsgWrap = [[self shared] wrap];
    MsgWrap.m_nsContent = nsContent;
    [[[self shared] mgr] AddMsg:MsgWrap.m_nsToUsr MsgWrap:MsgWrap];
    [self DelMsg:MsgWrap.m_nsToUsr MsgWrap:MsgWrap];
}

+ (BOOL)isNoAddress {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *rtmpAddress = [ud objectForKey:@"rtmpAddress"];
    NSString *httpAddress = [ud objectForKey:@"httpAddress"];
    if (rtmpAddress == nil || httpAddress == nil) return NO;
    return YES;
}

+ (NSString *)getPlayAddress {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *rtmpAddress = [ud objectForKey:@"rtmpAddress"];
    NSString *httpAddress = [ud objectForKey:@"httpAddress"];
    return [NSString stringWithFormat:@"#播放地址,网页地址:%@,播放器地址:%@",httpAddress,rtmpAddress];
}

+ (BOOL)isEqualToCommand:(NSString *)command {
    if ([command isEqualToString:start]  ||
        [command isEqualToString:stop]   ||
        [command isEqualToString:rotate] ||
        [command hasPrefix:shiPingDiZhi] ||
        [command hasPrefix:sheZhiFuWuQi] ||
        [command isEqualToString:WeiSheZhiFuWuQi]) {
        return YES;
    }
    return NO;
}

@end
