//
//  SelectedObjectMarker.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/5/21.
//

#pragma once

#include "Component.hpp"

namespace hero {

class LineRenderer;
class TextureRenderer;

class SelectedObjectMarker: public CompositeComponent {
protected:
    using CompositeComponent::CompositeComponent;
    
    void onStart() override;
    void onComponentDidAdd(ComponentTypeInfo typeInfo, Component* component) override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component* component) override;
  
private:
    template <typename RT>
    void setupSelection(const RT* renderer);
};

}
