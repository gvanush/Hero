//
//  UIRepresentable.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#pragma once

#include "Object.hpp"

namespace hero {

class UIRepresentable: public Object {
public:
    
    inline void setNeedsUIUpdate() {
        _needsUIUpdate = true;
    }
    
    inline bool needsUIUpdate() const {
        return _needsUIUpdate;
    }
    
#ifdef __OBJC__
    
    inline void onUIUpdated() {
        _needsUIUpdate = false;
    }
    
#endif
    
protected:
    UIRepresentable() = default;
    
private:
    bool _needsUIUpdate = true;
};

}
