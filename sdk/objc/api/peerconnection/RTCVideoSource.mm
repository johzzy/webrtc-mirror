/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "RTCVideoSource+Private.h"

#include "pc/video_track_source_proxy.h"
#include "rtc_base/checks.h"
#include "sdk/objc/native/src/objc_video_track_source.h"

static webrtc::ObjCVideoTrackSource *getObjCVideoSource(
    const rtc::scoped_refptr<webrtc::VideoTrackSourceInterface> nativeSource) {
  webrtc::VideoTrackSourceProxy *proxy_source =
      static_cast<webrtc::VideoTrackSourceProxy *>(nativeSource.get());
  return static_cast<webrtc::ObjCVideoTrackSource *>(proxy_source->internal());
}

// TODO(magjed): Refactor this class and target ObjCVideoTrackSource only once
// RTCAVFoundationVideoSource is gone. See http://crbug/webrtc/7177 for more
// info.
@implementation RTC_OBJC_TYPE (RTCVideoSource) {
  rtc::scoped_refptr<webrtc::VideoTrackSourceInterface> _nativeVideoSource;
  id<CFVideoProcessor> _videoProcessor;
}

- (instancetype)initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
              nativeVideoSource:
                  (rtc::scoped_refptr<webrtc::VideoTrackSourceInterface>)nativeVideoSource {
  RTC_DCHECK(factory);
  RTC_DCHECK(nativeVideoSource);
  if (self = [super initWithFactory:factory
                  nativeMediaSource:nativeVideoSource
                               type:RTCMediaSourceTypeVideo]) {
    _nativeVideoSource = nativeVideoSource;
    _videoProcessor = nil;
  }
  return self;
}

- (instancetype)initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
              nativeMediaSource:(rtc::scoped_refptr<webrtc::MediaSourceInterface>)nativeMediaSource
                           type:(RTCMediaSourceType)type {
  RTC_NOTREACHED();
  return nil;
}

- (instancetype)initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
                signalingThread:(rtc::Thread *)signalingThread
                   workerThread:(rtc::Thread *)workerThread {
  rtc::scoped_refptr<webrtc::ObjCVideoTrackSource> objCVideoTrackSource(
      new rtc::RefCountedObject<webrtc::ObjCVideoTrackSource>());

  return [self initWithFactory:factory
             nativeVideoSource:webrtc::VideoTrackSourceProxy::Create(
                                   signalingThread, workerThread, objCVideoTrackSource)];
}

- (NSString *)description {
  NSString *stateString = [[self class] stringForState:self.state];
  return [NSString stringWithFormat:@"RTC_OBJC_TYPE(RTCVideoSource)( %p ): %@", self, stateString];
}

- (void)capturer:(RTC_OBJC_TYPE(RTCVideoCapturer) *)capturer
    didCaptureVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
  getObjCVideoSource(_nativeVideoSource)->OnCapturedFrame(frame);
}

- (void)adaptOutputFormatToWidth:(int)width height:(int)height fps:(int)fps {
  getObjCVideoSource(_nativeVideoSource)->OnOutputFormatRequest(width, height, fps);
}

// - (void)setVideoProcessor:(id<CFVideoProcessor>)processor {
//   @synchronized (self) {
//     if (_videoProcessor) {
//       [_videoProcessor setVideoProcessorDelegate:nil];
//     }
//     _videoProcessor = processor;
//     if (_videoProcessor) {
//       [_videoProcessor setVideoProcessorDelegate:self];
//     }
//   }
// }

- (void)onProcessedVideoFrame:(RTCVideoFrame *)frame {
  webrtc::ObjCVideoTrackSource *objcSource = getObjCVideoSource(_nativeVideoSource);
  if (objcSource) {
    objcSource->OnCapturedFrame(frame);
  }
}

#pragma mark - Private

- (rtc::scoped_refptr<webrtc::VideoTrackSourceInterface>)nativeVideoSource {
  return _nativeVideoSource;
}

@end
