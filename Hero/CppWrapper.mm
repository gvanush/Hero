//
//  CppWrapper.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"

@interface CppWrapper ()
    
@property (nonatomic, readwrite) CppHandleDeleter deleter;

@end

@implementation CppWrapper

-(instancetype) initWithOwnedCpp: (hero::ObjCWrappee*) cpp deleter: (CppHandleDeleter) deleter {
    if (self = [super init]) {
        if (!cpp) {
            return nil;
        }
        _cppHandle = cpp;
        _deleter = deleter;
        cpp->setObjCHandle((__bridge hero::ObjCHandle) self);
    }
    return self;
}

-(instancetype) initWithCpp: (hero::ObjCWrappee*) cpp {
    return [self initWithOwnedCpp: cpp deleter: nil];
}

-(void)dealloc {
    if(self.deleter) {
        self.deleter(self.cppHandle);
    }
}

@end
