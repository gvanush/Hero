//
//  Singleton.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/12/20.
//

#pragma once

namespace hero {

template <typename T>
class Singleton {
public:

    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton&) = delete;
    Singleton(Singleton&&) = delete;
    Singleton& operator=(Singleton&&) = delete;
    
    static T& shared() {
        static T obj;
        return obj;
    }
    
protected:
    Singleton() = default;
};

}
