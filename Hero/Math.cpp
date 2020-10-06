//
//  Math.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/28/20.
//

#include "Math.hpp"
#include "Numeric.hpp"

namespace hero {

simd::float4x4 makeTranslationMatrix(float tx, float ty, float tz) {
    using namespace simd;
    return float4x4 {
        float4 {1.f , 0.f, 0.f, tx},
        float4 {0.f, 1.f, 0.f, ty},
        float4 {0.f, 0.f, 1.f, tz},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd::float4x4 makeTranslationMatrix(const simd::float3& t) {
    return makeTranslationMatrix(t.x, t.y, t.z);
}

simd::float4x4 makeScaleMatrix(float sx, float sy, float sz) {
    return simd::float4x4 {simd::float4 {sx, sy, sz, 1.f}};
}

simd::float4x4 makeScaleMatrix(const simd::float3& s) {
    return makeScaleMatrix(s.x, s.y, s.z);
}

simd::float4x4 makeRotationXMatrix(float rx) {
    const auto c = cosf(rx);
    const auto s = sinf(rx);
    using namespace simd;
    return simd::float4x4 {
        float4 {1.f, 0.f, 0.f, 0.f},
        float4 {0.f, c, -s, 0.f},
        float4 {0.f, s, c, 0.f},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd::float4x4 makeRotationYMatrix(float ry) {
    const auto c = cosf(ry);
    const auto s = sinf(ry);
    using namespace simd;
    return simd::float4x4 {
        float4 {c, 0.f, s, 0.f},
        float4 {0.f, 1.f, 0.f, 0.f},
        float4 {-s, 0.f, c, 0.f},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd::float4x4 makeRotationZMatrix(float rz) {
    const auto c = cosf(rz);
    const auto s = sinf(rz);
    using namespace simd;
    return simd::float4x4 {
        float4 {c, -s, 0.f, 0.f},
        float4 {s, c, 0.f, 0.f},
        float4 {0.f, 0.f, 1.f, 0.f},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd::float4x4 makeOrthographicMatrix(float l, float r, float b, float t, float n, float f) {
    using namespace simd;
    return float4x4 {
        float4 {2.f / (r - l), 0.f, 0.f, (l + r) / (l - r)},
        float4 {0.f, 2.f / (t - b), 0.f, (b + t) / (b - t)},
        float4 {0.f, 0.f, 1.f / (f - n), n / (n - f)},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd::float4x4 makePerspectiveMatrix(float fovy, float aspectRatio, float n, float f) {
    const auto c = 1.f / tanf(0.5f * fovy);
    using namespace simd;
    return float4x4 {
        float4 {c / aspectRatio, 0.f, 0.f, 0.f},
        float4 {0.f, c, 0.f, 0.f},
        float4 {0.f, 0.f, f / (f - n), f * n / (n - f)},
        float4 {0.f, 0.f, 1.f, 0.f}
    };
}

simd::float4x4 makeViewportMatrix(const Size2& screenSize) {
    using namespace simd;
    return float4x4 {
        float4 {0.5f * screenSize.width, 0.f, 0.f, 0.5f * screenSize.width},
        float4 {0.f, -0.5f * screenSize.height, 0.f, 0.5f * screenSize.height},
        float4 {0.f, 0.f, 1.f, 0.f},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd::float3x3 makeLookAtMatrix(const simd::float3& pos, const simd::float3& target, const simd::float3& up) {
    using namespace simd;
    auto zAxis = normalize(target - pos);
    auto xAxis = normalize(cross(up, zAxis));
    auto yAxis = normalize(cross(zAxis, xAxis));
    return float3x3 {
        float3 {xAxis.x, yAxis.x, zAxis.x},
        float3 {xAxis.y, yAxis.y, zAxis.y},
        float3 {xAxis.z, yAxis.z, zAxis.z}
    };
}

simd::float3 getRotationMatrixEulerAngles(const simd::float3x3& rotMat, EulerOrder eulerOrder) {
    using namespace simd;
    
    constexpr auto kTolerance = 0.0001f;
    simd::float3 angles {};
    switch (eulerOrder) {
        case EulerOrder_xyz: {
            angles.y = asinf(-rotMat.columns[2][0]);
            if (isNearlyZero(cosf(angles.y), kTolerance)) {
                angles.z = atan2f(-rotMat.columns[0][1], rotMat.columns[1][1]);
            } else {
                angles.x = atan2f(rotMat.columns[2][1], rotMat.columns[2][2]);
                angles.z = atan2f(rotMat.columns[1][0], rotMat.columns[0][0]);
            }
            break;
        }
        case EulerOrder_xzy: {
            angles.z = asinf(rotMat.columns[1][0]);
            if (isNearlyZero(cosf(angles.z), kTolerance)) {
                angles.x = atan2f(rotMat.columns[2][1], rotMat.columns[2][2]);
            } else {
                angles.x = atan2f(-rotMat.columns[1][2], rotMat.columns[1][1]);
                angles.y = atan2f(-rotMat.columns[2][0], rotMat.columns[0][0]);
            }
            break;
        }
        case EulerOrder_yxz: {
            angles.x = asinf(rotMat.columns[2][1]);
            if (isNearlyZero(cosf(angles.x), kTolerance)) {
                angles.y = atan2f(rotMat.columns[0][2], rotMat.columns[0][0]);
            } else {
                angles.y = atan2f(-rotMat.columns[0][2], rotMat.columns[2][2]);
                angles.z = atan2f(-rotMat.columns[0][1], rotMat.columns[1][1]);
            }
            break;
        }
        case EulerOrder_yzx: {
            angles.z = asinf(-rotMat.columns[0][1]);
            if (isNearlyZero(cosf(angles.z), kTolerance)) {
                angles.x = atan2f(-rotMat.columns[1][2], rotMat.columns[2][2]);
            } else {
                angles.y = atan2f(rotMat.columns[0][2], rotMat.columns[0][0]);
                angles.x = atan2f(rotMat.columns[2][1], rotMat.columns[1][1]);
            }
            break;
        }
        case EulerOrder_zxy: {
            angles.x = asinf(-rotMat.columns[1][2]);
            if (isNearlyZero(cosf(angles.x), kTolerance)) {
                angles.z = atan2f(-rotMat.columns[0][1], rotMat.columns[0][0]);
            } else {
                angles.y = atan2f(rotMat.columns[0][2], rotMat.columns[2][2]);
                angles.z = atan2f(rotMat.columns[1][0], rotMat.columns[1][1]);
            }
            break;
        }
        case EulerOrder_zyx: {
            angles.y = asinf(rotMat.columns[0][2]);
            if (isNearlyZero(cosf(angles.y), kTolerance)) {
                angles.z = atan2f(rotMat.columns[1][0], rotMat.columns[1][1]);
            } else {
                angles.x = atan2f(-rotMat.columns[1][2], rotMat.columns[2][2]);
                angles.z = atan2f(-rotMat.columns[0][1], rotMat.columns[0][0]);
            }
            break;
        }
    }
    
    return angles;
}

}
