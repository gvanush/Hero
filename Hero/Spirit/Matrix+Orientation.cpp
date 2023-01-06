//
//  Matrix+Orientation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.01.23.
//

#include "Matrix+Orientation.h"

#include <cmath>


simd_float3x3 SPTMatrix3x3CreateEulerXOrientation(float rx) {
    const auto c = cosf(rx);
    const auto s = sinf(rx);
    return simd_float3x3 {
        simd_float3 {1.f, 0.f, 0.f},
        simd_float3 {0.f, c, s},
        simd_float3 {0.f, -s, c}
    };
}

simd_float3x3 SPTMatrix3x3CreateEulerYOrientation(float ry) {
    const auto c = cosf(ry);
    const auto s = sinf(ry);
    return simd_float3x3 {
        simd_float3 {c, 0.f, -s},
        simd_float3 {0.f, 1.f, 0.f},
        simd_float3 {s, 0.f, c}
    };
}

simd_float3x3 SPTMatrix3x3CreateEulerZOrientation(float rz) {
    const auto c = cosf(rz);
    const auto s = sinf(rz);
    return simd_float3x3 {
        simd_float3 {c, s, 0.f},
        simd_float3 {-s, c, 0.f},
        simd_float3 {0.f, 0.f, 1.f},
    };
}


simd_float3x3 SPTMatrix3x3CreateEulerXYZOrientation(simd_float3 angles) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerXOrientation(angles.x);
    const auto& yMat = SPTMatrix3x3CreateEulerYOrientation(angles.y);
    const auto& zMat = SPTMatrix3x3CreateEulerZOrientation(angles.z);
    
    return simd_mul(zMat, simd_mul(yMat, xMat));
}

simd_float3x3 SPTMatrix3x3CreateEulerXZYOrientation(simd_float3 angles) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerXOrientation(angles.x);
    const auto& yMat = SPTMatrix3x3CreateEulerYOrientation(angles.y);
    const auto& zMat = SPTMatrix3x3CreateEulerZOrientation(angles.z);
    
    return simd_mul(yMat, simd_mul(zMat, xMat));
}

simd_float3x3 SPTMatrix3x3CreateEulerYXZOrientation(simd_float3 angles) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerXOrientation(angles.x);
    const auto& yMat = SPTMatrix3x3CreateEulerYOrientation(angles.y);
    const auto& zMat = SPTMatrix3x3CreateEulerZOrientation(angles.z);
    
    return simd_mul(zMat, simd_mul(xMat, yMat));
}

simd_float3x3 SPTMatrix3x3CreateEulerYZXOrientation(simd_float3 angles) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerXOrientation(angles.x);
    const auto& yMat = SPTMatrix3x3CreateEulerYOrientation(angles.y);
    const auto& zMat = SPTMatrix3x3CreateEulerZOrientation(angles.z);
    
    return simd_mul(xMat, simd_mul(zMat, yMat));
}

simd_float3x3 SPTMatrix3x3CreateEulerZXYOrientation(simd_float3 angles) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerXOrientation(angles.x);
    const auto& yMat = SPTMatrix3x3CreateEulerYOrientation(angles.y);
    const auto& zMat = SPTMatrix3x3CreateEulerZOrientation(angles.z);
    
    return simd_mul(yMat, simd_mul(xMat, zMat));
}

simd_float3x3 SPTMatrix3x3CreateEulerZYXOrientation(simd_float3 angles) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerXOrientation(angles.x);
    const auto& yMat = SPTMatrix3x3CreateEulerYOrientation(angles.y);
    const auto& zMat = SPTMatrix3x3CreateEulerZOrientation(angles.z);
    
    return simd_mul(xMat, simd_mul(yMat, zMat));
}


simd_float3 SPTMatrix3x3GetEulerXYZOrientationAngles(simd_float3x3 matrix) {
    
    const auto cosY = 1 - matrix.columns[0][2] * matrix.columns[0][2];
    
    simd_float3 angles {0.f, asinf(-matrix.columns[0][2]), 0.f};
    
    if(cosY < 0.0001) {
        angles.z = atan2(-matrix.columns[1][0], matrix.columns[2][0]);
    } else {
        angles.x = atan2(matrix.columns[1][2], matrix.columns[2][2]);
        angles.z = atan2(matrix.columns[0][1], matrix.columns[0][0]);
    }
    
    return angles;
}

simd_float3 SPTMatrix3x3GetEulerXZYOrientationAngles(simd_float3x3 matrix) {
    
    const auto cosZ = 1 - matrix.columns[0][1] * matrix.columns[0][1];
    
    simd_float3 angles {0.f, 0.f, asinf(matrix.columns[0][1])};
    
    if(cosZ < 0.0001) {
        angles.y = atan2(-matrix.columns[2][0], matrix.columns[2][2]);
    } else {
        angles.x = atan2(-matrix.columns[2][1], matrix.columns[1][1]);
        angles.y = atan2(-matrix.columns[0][2], matrix.columns[0][0]);
    }
    
    return angles;
}

simd_float3 SPTMatrix3x3GetEulerYXZOrientationAngles(simd_float3x3 matrix) {
    
    const auto cosX = 1 - matrix.columns[1][2] * matrix.columns[1][2];
    
    simd_float3 angles {asinf(matrix.columns[1][2]), 0.f, 0.f};
    
    if(cosX < 0.0001) {
        angles.z = atan2(matrix.columns[0][1], matrix.columns[0][0]);
    } else {
        angles.y = atan2(-matrix.columns[0][2], matrix.columns[2][2]);
        angles.z = atan2(-matrix.columns[1][0], matrix.columns[1][1]);
    }
    
    return angles;
    
}

simd_float3 SPTMatrix3x3GetEulerYZXOrientationAngles(simd_float3x3 matrix) {
    
    const auto cosZ = 1 - matrix.columns[1][0] * matrix.columns[1][0];
    
    simd_float3 angles {0.f, 0.f, asinf(-matrix.columns[1][0])};
    
    if(cosZ < 0.0001) {
        angles.x = atan2(-matrix.columns[2][1], matrix.columns[2][2]);
    } else {
        angles.x = atan2(matrix.columns[1][2], matrix.columns[1][1]);
        angles.y = atan2(matrix.columns[2][0], matrix.columns[0][0]);
    }
    
    return angles;
    
}

simd_float3 SPTMatrix3x3GetEulerZXYOrientationAngles(simd_float3x3 matrix) {
    
    const auto cosX = 1 - matrix.columns[2][1] * matrix.columns[2][1];
    
    simd_float3 angles {asinf(-matrix.columns[2][1]), 0.f, 0.f};
    
    if(cosX < 0.0001) {
        angles.y = atan2(-matrix.columns[0][2], matrix.columns[0][0]);
    } else {
        angles.y = atan2(matrix.columns[2][0], matrix.columns[2][2]);
        angles.z = atan2(matrix.columns[0][1], matrix.columns[1][1]);
    }
    
    return angles;
    
}

simd_float3 SPTMatrix3x3GetEulerZYXOrientationAngles(simd_float3x3 matrix) {
    
    const auto cosY = 1 - matrix.columns[2][0] * matrix.columns[2][0];
    
    simd_float3 angles {0.f, asinf(matrix.columns[2][0]), 0.f};
    
    if(cosY < 0.0001) {
        angles.x = atan2(matrix.columns[1][2], matrix.columns[1][1]);
    } else {
        angles.x = atan2(-matrix.columns[2][1], matrix.columns[2][2]);
        angles.z = atan2(-matrix.columns[1][0], matrix.columns[0][0]);
    }
    
    return angles;
}
