//
//  ResourceOptionsUtil_metal.h
//  Hero
//
//  Created by Vanush Grigoryan on 26.11.21.
//

#include "ResourceOptions.hpp"

#import <Metal/Metal.h>

namespace spt::ghi {

inline MTLResourceOptions toMTLResourceOptions(CPUCacheMode cacheMode) {
    switch (cacheMode) {
        case CPUCacheMode::default_:
            return MTLResourceCPUCacheModeDefaultCache;
        case CPUCacheMode::writeCombined:
            return MTLResourceCPUCacheModeWriteCombined;
    }
}

inline MTLResourceOptions toMTLResourceOptions(StorageMode storageMode) {
    switch (storageMode) {
        case StorageMode::shared:
            return MTLResourceStorageModeShared;
        case StorageMode::private_:
            return MTLResourceStorageModePrivate;
        case StorageMode::memoryless:
            return MTLResourceStorageModeMemoryless;
    }
}

inline MTLResourceOptions toMTLResourceOptions(HazardTrackingMode hazardTrackingMode) {
    switch (hazardTrackingMode) {
        case HazardTrackingMode::default_:
            return MTLResourceHazardTrackingModeDefault;
        case HazardTrackingMode::untracked:
            return MTLResourceHazardTrackingModeUntracked;
        case HazardTrackingMode::tracked:
            return MTLResourceHazardTrackingModeTracked;
    }
}

}
