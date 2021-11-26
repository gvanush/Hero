//
//  APIObjectWrapper.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 25.11.21.
//

#pragma once

namespace spt::ghi {

class APIObjectWrapper {
public:
    APIObjectWrapper(const APIObjectWrapper&) = delete;
    APIObjectWrapper(APIObjectWrapper&&) = delete;
    APIObjectWrapper& operator=(const APIObjectWrapper&) = delete;
    APIObjectWrapper& operator=(APIObjectWrapper&&) = delete;
    
    void* apiObject() const;
    
protected:
    APIObjectWrapper(void* apiObject);
    ~APIObjectWrapper();
    
private:
    void* _apiObject;
};

inline void* APIObjectWrapper::apiObject() const {
    return _apiObject;
}

}
