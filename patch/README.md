WebRTC FFmpeg Patch
-------------------

Android WebRTC 开启 FFmpeg 解码和 OpenH264 编码

# ffmpeg commit in .gclient_entries
```
'src/third_party/ffmpeg': 'https://chromium.googlesource.com/chromium/third_party/ffmpeg.git@6d9096c9e3f7f5d4e6528104ed77987ec9327315',
'src/third_party/ffmpeg': 'https://chromium.googlesource.com/chromium/third_party/ffmpeg.git@841aa72c9e153ae5f952e31e4b6406870555922d',
```

# create patch
```
cd ${root}/third_party/ffmpeg
git diff > ${root}/patch/ffmpeg.patch
```

# apply patch
```
git apply --stat   ${root}/patch/ffmpeg.patch
git apply --check  ${root}/patch/ffmpeg.patch
git am --signoff < ${root}/patch/ffmpeg.patch
```


# build
```
# update
gclient sync
grep ffmpeg ../.gclient_entries
cd ${root}/third_party/ffmpeg


# ios webrtc framework
./tools_webrtc/ios/build_ios_libs.py --arch arm64 --output-dir out/ios_libs --extra-gn-args 'proprietary_codecs=true' # ok
./tools_webrtc/ios/build_ios_libs.py --arch arm64 --output-dir out/ios_libs --extra-gn-args 'proprietary_codecs=true rtc_use_h264=true' # failed

./tools_webrtc/ios/build_ios_libs.py --arch arm arm64 --output-dir out/ios_libs --extra-gn-args 'is_debug=true proprietary_codecs=true' # ok

gn args out/ios_libs --list=proprietary_codecs
gn args out/ios_libs --list=rtc_use_h264


# mac AppRTCMobile
gn gen out/Debug --ide=xcode --args='rtc_include_tests=true is_debug=true enable_dsyms=true rtc_enable_symbol_export=true symbol_level=2 is_component_build=false proprietary_codecs=true' # ok
gn gen out/Debug --ide=xcode --args='is_debug=true proprietary_codecs=true rtc_use_h264=true'  # failed
ninja -C out/Debug AppRTCMobile

gn args out/Debug --list=proprietary_codecs
gn args out/Debug --list=rtc_use_h264

# ios 
gn gen out/ios_64 --args='target_os="ios" target_cpu="arm64" rtc_include_tests=true is_debug=true enable_dsyms=true rtc_enable_symbol_export=true symbol_level=2 is_component_build=false proprietary_codecs=true'
ninja -C out/ios_64 AppRTCMobile

# android webrtc aar 
./tools_webrtc/android/build_aar.py --arch armeabi-v7a  arm64-v8a  --build-dir out  --extra-gn-args='ffmpeg_branding="Chrome" proprietary_codecs=true rtc_use_h264=true'

# android AppRTCMobile
gn gen out/arm64-v8a --args='target_os="android" target_cpu="arm64" rtc_include_tests=false is_debug=true ffmpeg_branding="Chrome" proprietary_codecs=true rtc_use_h264=true'
ninja -C out/arm64-v8a AppRTCMobile

gn args out/arm64-v8a --list=rtc_use_h264
gn args out/arm64-v8a --list=proprietary_codecs
```


# webrtc android h264 参考

    http://www.voycn.com/article/android-webrtcxuexisankaiqiffmpegjiemaheopenh264bianma
    https://blog.csdn.net/ydjjcdd/article/details/111190392

# 支持 openh264 和 ffmpeg 相关注释

    // NOTE(h264-fmtp): 'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f' for h264 encoder
    // NOTE(h264-fmtp): 'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f' for h264 decoder
