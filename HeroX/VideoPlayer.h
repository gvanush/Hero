//
//  VideoPlayer.h
//  HeroX
//
//  Created by Vanush Grigoryan on 2/7/21.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class VideoPlayer;

@protocol VideoPlayerDelegate <NSObject>

-(void) videoPlayerDidBecomeReady: (VideoPlayer*) videoPlayer;

@end

@interface VideoPlayer : NSObject

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithURL: (NSURL*) url;

-(void) play;
-(void) update: (CFTimeInterval) time;

@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, readwrite, weak) id<VideoPlayerDelegate> delegate;

@property (nonatomic, readonly) CGSize videoSize;
@property (nonatomic, readonly) CGAffineTransform preferredVideoTransform;

@property (nonatomic, readonly) id<MTLTexture> lumaTexture;
@property (nonatomic, readonly) id<MTLTexture> chromaTexture;

@end

NS_ASSUME_NONNULL_END
