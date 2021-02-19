//
//  VideoPlayer.m
//  HeroX
//
//  Created by Vanush Grigoryan on 2/7/21.
//

#import "VideoPlayer.h"
#import "RenderingContext.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

static const void* PlayerItemContext = NULL;

@interface VideoPlayer () {
    AVAsset* _asset;
    AVPlayerItem* _playerItem;
    AVPlayerItemVideoOutput* _videoOutput;
    AVPlayer* _player;
}

@end

@implementation VideoPlayer

-(instancetype) initWithURL: (NSURL*) url {
    if(self = [super init]) {
        _asset = [[AVURLAsset alloc] initWithURL: url options: nil];
        
        _playerItem = [[AVPlayerItem alloc] initWithAsset: _asset];
        [_playerItem addObserver: self forKeyPath: @"status" options: NSKeyValueObservingOptionNew context: &PlayerItemContext];
        
        _player = [[AVPlayer alloc] initWithPlayerItem: _playerItem];
        
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // Only handle observations for the PlayerItemContext
    if (context != &PlayerItemContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
 
    if ([keyPath isEqualToString: @"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass: [NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"VideoPlayer: Ready to play");
                
                [_playerItem removeObserver: self forKeyPath: @"status"];
                
                _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithOutputSettings: @{
                    AVVideoAllowWideColorKey : @YES,
                    (__bridge NSString*) kCVPixelBufferMetalCompatibilityKey : @YES,
                }];

                [_playerItem addOutput:_videoOutput];
                [self.delegate videoPlayerDidBecomeReady: self];
                
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"VideoPlayer: Error (%@)", _playerItem.error.localizedDescription);
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"VideoPlayer: Not yet ready to play");
                break;
        }
    }
}

-(BOOL)isPlaying {
    return _player.rate > 0.f;
}

-(CGSize) videoSize {
    return [_asset tracksWithMediaType: AVMediaTypeVideo].firstObject.naturalSize;
}

-(CGAffineTransform)preferredVideoTransform {
    return [_asset tracksWithMediaType: AVMediaTypeVideo].firstObject.preferredTransform;
}

-(void) play {
    [_player play];
}

-(void) update: (CFTimeInterval) time {
    
    if(!_videoOutput) {
        return;
    }
    
    CMTime itemTime = [_videoOutput itemTimeForHostTime: time];
    if ([_videoOutput hasNewPixelBufferForItemTime: itemTime]) {
        CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime: itemTime itemTimeForDisplay: nil];
        
        if (CVPixelBufferGetPlaneCount(pixelBuffer) >= 2) {
            _lumaTexture = [self createTextureFromPixelBuffer: pixelBuffer pixelFormat: MTLPixelFormatR8Unorm planeIndex: 0];
            _chromaTexture = [self createTextureFromPixelBuffer: pixelBuffer pixelFormat: MTLPixelFormatRG8Unorm planeIndex: 1];
        }
        
        CVBufferRelease(pixelBuffer);
    }
}

-(id<MTLTexture>) createTextureFromPixelBuffer: (CVPixelBufferRef) pixelBuffer pixelFormat: (MTLPixelFormat) pixelFormat planeIndex: (size_t) planeIndex {
    
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex);
    
    CVMetalTextureRef texture;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [RenderingContext defaultCVMetalTextureCache], pixelBuffer, NULL, pixelFormat, width, height, planeIndex, &texture);
    if (status == kCVReturnSuccess) {
        id<MTLTexture> mtlTexture = CVMetalTextureGetTexture(texture);
        
        // WARNING: Maybe 'texture' must be released after rendering is done, documentation is ambiguous but so far it works
        // Check 'CVMetalTextureCacheCreateTextureFromImage' reference for more info
        CVBufferRelease(texture);
        
        return mtlTexture;
    }
    return nil;
}

@end
