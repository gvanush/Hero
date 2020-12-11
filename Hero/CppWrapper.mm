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

-(instancetype) initWithOwnedCpp: (CppHandle) cpp deleter: (CppHandleDeleter) deleter {
    if (self = [super init]) {
        if (!cpp) {
            return nil;
        }
        _cppHandle = cpp;
        _deleter = deleter;
    }
    return self;
}

-(instancetype) initWithUnownedCpp: (CppHandle) cpp {
    if (self = [super init]) {
        if (!cpp) {
            return nil;
        }
        _cppHandle = cpp;
    }
    return self;
}

-(void)dealloc {
    if(self.deleter) {
        self.deleter(self.cppHandle);
    }
}

@end
