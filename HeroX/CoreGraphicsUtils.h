//
//  CoreGraphicsUtils.h
//  Hero
//
//  Created by Vanush Grigoryan on 2/13/21.
//

#import <CoreGraphics/CoreGraphics.h>
#import <simd/simd.h>

inline simd_float2x3 toFloat3x2(CGAffineTransform transform) {
    return simd_matrix(simd_make_float3(transform.a, transform.c, transform.tx), simd_make_float3(transform.b, transform.d, transform.ty));
}

inline simd_float3x3 toFloat3x3(CGAffineTransform transform) {
    return simd_matrix(simd_make_float3(transform.a, transform.c, transform.tx), simd_make_float3(transform.b, transform.d, transform.ty), simd_make_float3(0.f, 0.f, 1.f));
}

inline simd_float2x2 toFloat2x2(CGAffineTransform transform) {
    return simd_matrix(simd_make_float2(transform.a, transform.c), simd_make_float2(transform.b, transform.d));
}

inline simd_float2 toFloat2(CGSize size) {
    return  simd_make_float2(size.width, size.height);
}
