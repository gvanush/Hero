//
//  UIRepresentable.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#pragma once

#include "ObjCWrappee.hpp"
#include "Renderer_Common.h"

#include <limits>

namespace hero {

class UIRepresentable: public ObjCWrappee {
public:
    
    inline void setNeedsUIUpdate() {
        _rendererFlags = std::numeric_limits<RendererFlag>::max();
    }
    
    inline bool needsUIUpdate(RendererFlag flag) const {
        return flag & _rendererFlags;
    }
    
#ifdef __OBJC__
    
    inline void onUIUpdated(RendererFlag flag) {
        _rendererFlags &= (~flag);
    }
    
#endif
    
protected:
    UIRepresentable() {
        setNeedsUIUpdate();
    }
    
private:
    RendererFlag _rendererFlags;
};

}
