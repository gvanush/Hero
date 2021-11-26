//
//  ResourceOptions.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 26.11.21.
//

#pragma once

namespace spt::ghi {

enum class CPUCacheMode {
    default_,
    writeCombined
};

enum class StorageMode {
    shared,
    private_,
    memoryless
};

enum class HazardTrackingMode {
    default_,
    untracked,
    tracked
};

}
