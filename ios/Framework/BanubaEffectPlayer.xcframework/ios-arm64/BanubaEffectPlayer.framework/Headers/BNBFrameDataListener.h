// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from effect_player.djinni

#import "BNBFrameData.h"
#import <Foundation/Foundation.h>


/** Callback to get freshly processed frame_data. */
@protocol BNBFrameDataListener

/** Will be called only when amount of found faces changes. */
- (void)onFrameDataProcessed:(nullable BNBFrameData *)frameData;

@end
