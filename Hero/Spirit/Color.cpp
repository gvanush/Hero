//
//  Color.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 05.11.22.
//

#include "Color.h"

#include <algorithm>

bool SPTRGBAColorValidate(SPTRGBAColor color) {
    return color.red >= 0.f && color.red <= 1.0
    && color.green >= 0.f && color.green <= 1.0
    && color.blue >= 0.f && color.blue <= 1.0
    && color.alpha >= 0.f && color.alpha <= 1.0;
}

bool SPTRGBAColorEqual(SPTRGBAColor lhs, SPTRGBAColor rhs) {
    return simd_equal(lhs.float4, rhs.float4);
}

bool SPTHSBAColorValidate(SPTHSBAColor color) {
    return color.hue >= 0.f && color.hue <= 1.0
    && color.saturation >= 0.f && color.saturation <= 1.0
    && color.brightness >= 0.f && color.brightness <= 1.0
    && color.alpha >= 0.f && color.alpha <= 1.0;
}

bool SPTHSBAColorEqual(SPTHSBAColor lhs, SPTHSBAColor rhs) {
    return simd_equal(lhs.float4, rhs.float4);
}

bool SPTColorValidate(SPTColor color) {
    switch (color.model) {
        case SPTColorModelRGB:
            return SPTRGBAColorValidate(color.rgba);
        case SPTColorModelHSB:
            return SPTHSBAColorValidate(color.hsba);
    }
}

bool SPTColorEqual(SPTColor lhs, SPTColor rhs) {
    if(lhs.model != rhs.model) {
        return false;
    }
    
    switch (lhs.model) {
        case SPTColorModelRGB:
            return SPTRGBAColorEqual(lhs.rgba, rhs.rgba);
        case SPTColorModelHSB:
            return SPTHSBAColorEqual(lhs.hsba, rhs.hsba);
    }
}

SPTColor SPTColorToRGBA(SPTColor color) {
    
    switch (color.model) {
        case SPTColorModelRGB:
            return color;
        case SPTColorModelHSB:
            return { SPTColorModelRGB, {.rgba = SPTHSBAColorToRGBA(color.hsba)} };
    }
    
}

SPTColor SPTColorToHSBA(SPTColor color) {
    
    switch (color.model) {
        case SPTColorModelRGB:
            return { SPTColorModelHSB, {.hsba = SPTRGBAColorToHSBA(color.rgba)} };
        case SPTColorModelHSB:
            return color;
    }
    
}

SPTHSBAColor SPTRGBAColorToHSBA(SPTRGBAColor rgba) {
    
    const auto max = std::max({ rgba.red, rgba.green, rgba.blue });
    const auto c = max - std::min({ rgba.red, rgba.green, rgba.blue }); // Chroma

    SPTHSBAColor hsba { {
        0.f,
        (max != 0.f ? c / max : 0.f),
        max,
        rgba.alpha
    } };

    if (c != 0.f) {
        if (max == rgba.red) {
            hsba.hue = (rgba.green - rgba.blue) / c;
        } else if (max == rgba.green) {
            hsba.hue = ((rgba.blue - rgba.red) / c) + 2;
        } else if (max == rgba.blue) {
            hsba.hue = ((rgba.red - rgba.green) / c) + 4;
        }

        hsba.hue /= 6.f;
        
        if (hsba.hue < 0.f) {
            hsba.hue += 1.f;
        }
    }

    return hsba;
    
}

SPTRGBAColor SPTHSBAColorToRGBA(SPTHSBAColor hsba) {

    const auto c = hsba.saturation * hsba.brightness; // Chroma
    const auto h = hsba.hue * 6.f;
    const auto x = c * (1 - std::fabs(std::fmod(h, 2.f) - 1));
    const auto m = hsba.brightness - c;

    SPTRGBAColor rgba { {m, m, m, hsba.alpha} };

    switch(static_cast<int>(h)) {
        default: {
            rgba.red += c;
            rgba.green += x;
            break;
        }
        case 1: {
            rgba.red += x;
            rgba.green += c;
            break;
        }
        case 2: {
            rgba.green += c;
            rgba.blue += x;
            break;
        }
        case 3: {
            rgba.green += x;
            rgba.blue += c;
            break;
        }
        case 4: {
            rgba.red += x;
            rgba.blue += c;
            break;
        }
        case 5: {
            rgba.red += c;
            rgba.blue += x;
            break;
        }
    }
    
    return rgba;
}
