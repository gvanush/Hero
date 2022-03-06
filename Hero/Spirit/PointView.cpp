//
//  PointView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 04.03.22.
//

#include "PointView.h"
#include "Scene.hpp"


void SPTPointViewMake(SPTObject object, SPTPointView pointView) {
    spt::Scene::getRegistry(object).emplace<SPTPointView>(object.entity, pointView);
}

void SPTPointViewDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTPointView>(object.entity);
}
