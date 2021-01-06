//
//  Renderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/6/21.
//

#pragma once

#include "Component.hpp"

namespace hero {

class Renderer: public Component {
public:
    
    Renderer(SceneObject& sceneObject, Layer layer)
    : Component {sceneObject}
    , _layer {layer} {
        
    }
    
    inline Layer layer() const;
    
private:
    const Layer _layer;
};

Layer Renderer::layer() const {
    return _layer;
}

}
