//
//  UpdateLoop.m
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "UpdateLoop.h"

#import "UIRepresentable.h"
#import "NSPointerArray+Extensions.h"

@interface UpdateLoop () {
    NSMapTable<UIRepresentable*, NSPointerArray*>* _uiRepresentableToObservers;
    Scene* _scene;
    BOOL _isUpdatingUI;
}

@end

@implementation UpdateLoop

-(instancetype) initWithScene: (Scene*) scene {
    if (self = [super init]) {
        _uiRepresentableToObservers = [NSMapTable weakToStrongObjectsMapTable];
        _isUpdatingUI = false;
        _scene = scene;
    }
    return self;
}

-(void) addObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
    if (!observers) {
        observers = [NSPointerArray weakObjectsPointerArray];
        [_uiRepresentableToObservers setObject: observers forKey: uiRepresentable];
    }
    [observers addPointer: (__bridge void * _Nullable)(observer)];
}

-(void) removeObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
    NSUInteger index = [observers indexOfObjectPassingTest:^BOOL(id  _Nonnull object) {
        // Checking for 'nil' is needed becasue if the method is called
        // from the destructor of observer it is alread 'nil' in observers array
        return object == observer || object == nil;
    }];
    if(index != NSNotFound) {
        [observers removePointerAtIndex: index];
    }
}

-(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    [_uiRepresentableToObservers removeObjectForKey: uiRepresentable];
}

-(void) update {
    // TODO
    
    _isUpdatingUI = true;
    
    for (UIRepresentable* uiRepresentable in _uiRepresentableToObservers) {
        if (uiRepresentable.needsUIUpdate) {
            NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
            for (id<UIRepresentableObserver> observer in observers) {
                [observer onUIUpdateRequested];
            }
            [uiRepresentable onUIUpdated];
        }
    }
    
    _isUpdatingUI = false;
}

-(Scene*) scene {
    return _scene;
}

+(instancetype) shared {
    static UpdateLoop* updateLoop = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updateLoop = [[self alloc] initWithScene: Scene.shared];
    });
    return updateLoop;
}

@end
