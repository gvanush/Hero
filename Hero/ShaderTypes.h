#pragma once

#include <simd/simd.h>

namespace hero {

enum VertexInputIndex: unsigned int {
    kVertexInputIndexVertices     = 0,
    kVertexInputIndexViewportSize = 1,
    kVertexInputIndexSize = 2,
    kVertexInputIndexPosition = 3,
};

enum FragmentInputIndex: unsigned int {
    kFragmentInputIndexColor = 0,
    kFragmentInputIndexTexture = 1,
};

struct LayerVertex {
    simd::float2 position;
    simd::float2 texCoord;
};

}
