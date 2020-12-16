//
//  ComponentTypeInfo.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/16/20.
//

#pragma once

#include "GraphicsCoreUtils.hpp"

#include <functional>

namespace hero {

class ComponentTypeInfo {
public:
    
    ComponentTypeInfo(const ComponentTypeInfo&) = default;
    ComponentTypeInfo& operator=(const ComponentTypeInfo&) = default;
    
    using Id = std::uint32_t;
    
    template <typename CT>
    static std::enable_if_t<isConcreteComponent<CT>, ComponentTypeInfo> get() {
        Id id = ComponentTypeInfo::typeNumber<CT>;
        if constexpr (isCompositeComponent<CT>) {
            id |= kCompositeFlag;
        }
        return ComponentTypeInfo {id};
    }
    
    bool isComposite() const {
        return _id & kCompositeFlag;
    }
    
    Id id() const {
        return _id;
    }
    
private:
    
    ComponentTypeInfo(Id id)
    : _id {id} {
    }
    
    static std::uint8_t typeCount;
    
    template <typename  CT>
    static inline const std::uint8_t typeNumber = ++typeCount;
    
    static constexpr Id kCompositeFlag = (0x1 << 31);
    
    Id _id;
};

inline bool operator== (ComponentTypeInfo lhs, ComponentTypeInfo rhs) {
    return lhs.id() == rhs.id();
}

inline bool operator!= (ComponentTypeInfo lhs, ComponentTypeInfo rhs) {
    return !(lhs == rhs);
}

}

namespace std {

template <>
struct hash<hero::ComponentTypeInfo> {
    std::size_t operator() (hero::ComponentTypeInfo typeInfo) const {
        return std::hash<hero::ComponentTypeInfo::Id>()(typeInfo.id());
    }
};

}
