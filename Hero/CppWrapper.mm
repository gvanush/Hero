//
//  CppWrapper.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"
#import "UnownedCppWrapperRegistry.h"

@interface CppWrapper ()
    
-(instancetype) initWithUnownedCpp: (CppHandle) cpp NS_DESIGNATED_INITIALIZER;

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

+(instancetype) wrapperWithUnownedCpp: (CppHandle) cpp {
    CppWrapper* wrapper = hero::UnownedCppWrapperRegistry::shared().getWrapperFor(cpp);
    if (!wrapper) {
        wrapper = [[self alloc] initWithUnownedCpp: cpp];
        hero::UnownedCppWrapperRegistry::shared().addWrapper(wrapper);
    }
    return wrapper;
}

-(void)dealloc {
    if(self.deleter) {
        self.deleter(self.cppHandle);
    }
}

@end
