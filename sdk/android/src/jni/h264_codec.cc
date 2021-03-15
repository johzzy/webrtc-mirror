
#include <jni.h>

#include "modules/video_coding/codecs/h264/include/h264.h"
#include "sdk/android/generated_h264_jni/H264Decoder_jni.h"
#include "sdk/android/generated_h264_jni/H264Encoder_jni.h"
#include "sdk/android/src/jni/jni_helpers.h"


namespace webrtc {
namespace jni {

static jlong JNI_H264Encoder_CreateEncoder(JNIEnv* jni) {
  return jlongFromPointer(H264Encoder::Create(cricket::VideoCodec(cricket::kH264CodecName)).release());
}

static jboolean JNI_H264Encoder_IsSupported(JNIEnv* jni) {
  return !SupportedH264Codecs().empty();
}

static jlong JNI_H264Decoder_CreateDecoder(JNIEnv* jni) {
  return jlongFromPointer(H264Decoder::Create().release());
}

static jboolean JNI_H264Decoder_IsSupported(JNIEnv* jni) {
  return !SupportedH264Codecs().empty();
}

}  // namespace jni
}  // namespace webrtc
