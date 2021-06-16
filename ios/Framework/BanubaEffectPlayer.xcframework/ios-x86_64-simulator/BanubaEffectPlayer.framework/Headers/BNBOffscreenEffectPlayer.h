#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EPOrientation) {
    EPOrientationAngles0,
    EPOrientationAngles90,
    EPOrientationAngles180,
    EPOrientationAngles270

};


typedef struct
{
    CGSize cameraSize;
    CGSize screenSize;
    EPOrientation orientation;
    BOOL isMirrored;
    BOOL isYFlip; // if false, (0,0) in bottom left, else in top left
} EpImageFormat;

/**
 * All methods must be called from the same thread
 * (in which the object was created BNBOffscreenEffectPlayer)
 * All methods are synchronous
 *
 * WARNING: SDK should be initialized with BNBUtilityManager before BNBOfscreenEffectPlayer creating
 */
@interface BNBOffscreenEffectPlayer : NSObject

/*
 * effectWidth andHeight the size of the inner area where the effect is drawn
 */
- (instancetype)initWithEffectWidth:(NSUInteger)width
                          andHeight:(NSUInteger)height
                        manualAudio:(BOOL)manual;

/*
* EpImageFormat::cameraSize - input RGBA picture size
* EpImageFormat::screenSize not used
* the size of the output image is equal to the size of the inner area where the effect is drawn
*/
- (NSData*)processImage:(NSData*)inputRgba
             withFormat:(EpImageFormat*)imageFormat;

/*
* EpImageFormat::cameraSize - size of input Y image
* EpImageFormat::screenSize not used
* the size of the output image is equal to the size of the inner area where the effect is drawn
*/
- (nullable CVPixelBufferRef)processY:(NSData*)inputY andUV:(NSData*)inputUV
                           withFormat:(EpImageFormat*)imageFormat CF_RETURNS_RETAINED;

- (void)loadEffect:(NSString*)effectName;
- (void)unloadEffect;

/*
 *pause/resume controls only audio playback
 */
- (void)pause;
- (void)resume;

/*
 * When you use EffectPlayer with CallKit you should enable audio manually at the point when CallKit
 * notifies that its Audio Session is ready (its session is created in privileged mode, so it should be respected).
 */
- (void)enableAudio:(BOOL)enable;

- (void)callJsMethod:(NSString*)method withParam:(NSString*)param;

@end

NS_ASSUME_NONNULL_END
