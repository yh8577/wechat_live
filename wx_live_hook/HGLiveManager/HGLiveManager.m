//
//  HGLiveManager.m
//  iosPushAV
//
//  Created by jyh on 2018/7/31.
//  Copyright © 2018年 huig. All rights reserved.
//

#import "HGLiveManager.h"
#import "LFLiveKit.h"

@interface HGLiveManager()
@property (nonatomic, strong) LFLiveSession *liveSession;
@end

@implementation HGLiveManager

static HGLiveManager *_shared;
+ (instancetype)shared {
    if (!_shared) {
        _shared = [[self alloc] init];
    }
    return _shared;
}

- (instancetype)init {
    if (self = [super init]) {
        LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration defaultConfiguration];
        LFLiveVideoQuality videoQuality = LFLiveVideoQuality_Low1;
        LFLiveVideoConfiguration *aideoConfig = [LFLiveVideoConfiguration defaultConfigurationForQuality:videoQuality];
        self.liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfig videoConfiguration:aideoConfig];
    }
    return self;
}

- (void)startRunning {

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.liveSession.running = NO;
        self.liveSession.preView = [UIView new];
        LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
        streamInfo.url = [[NSUserDefaults standardUserDefaults] objectForKey:@"rtmpAddress"];
        [self.liveSession startLive:streamInfo];
        self.liveSession.running = YES;
    });
}

- (void)rotateCamera {
    
    if (!self.liveSession.running) return;
    AVCaptureDevicePosition position = self.liveSession.captureDevicePosition;
    self.liveSession.captureDevicePosition = position == AVCaptureDevicePositionBack?AVCaptureDevicePositionFront:AVCaptureDevicePositionBack;
}

- (void)stopLive{
    self.liveSession.running = NO;
}

@end
