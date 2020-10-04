//___FILEHEADER___

#import "___FILEBASENAME___.h"

#include "___FILEBASENAME___.hpp"

@implementation ___FILEBASENAME___

-(instancetype) init {
    if (self = [super initWithCppHandle: new hero::___FILEBASENAME___ {}]) {
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
}

@end

@implementation ___FILEBASENAME___ (Cpp)

-(hero::___FILEBASENAME___*) cpp {
    return static_cast<hero::___FILEBASENAME___*>(self.cppHandle);
}

@end
