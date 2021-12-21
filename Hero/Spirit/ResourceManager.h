//
//  ResourceManager.h
//  Hero
//
//  Created by Vanush Grigoryan on 19.11.21.
//

#pragma once

#include "Base.h"
#include "Mesh.h"
#include "Polyline.h"

#include <stdint.h>

SPT_EXTERN_C_BEGIN

SPTMeshId SPTCreate3DMeshFromFile(const char* path);
SPTMeshId SPTCreate2DMeshFromFile(const char* path);

SPTMeshId SPTCreatePolylineFromFile(const char* path);

SPT_EXTERN_C_END
