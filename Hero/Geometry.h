//
//  Geometry.h
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

typedef enum {
    EulerOrder_xyz,
    EulerOrder_xzy,
    EulerOrder_yxz,
    EulerOrder_yzx,
    EulerOrder_zxy,
    EulerOrder_zyx
} EulerOrder;

typedef enum {
    Projection_ortographic,
    Projection_perspective
} Projection;
