//___FILEHEADER___

#import "___FILEBASENAME___.h"

#include "___FILEBASENAME___.hpp"

#include <memory>

@interface ___FILEBASENAME___ () {
    std::unique_ptr<hero::Test> _cpp;
}

@end

@implementation ___FILEBASENAME___

-(CppHandle) cppHandle {
    return _cpp.get();
}

@end
