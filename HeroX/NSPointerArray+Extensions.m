//
//  NSPointerArray+Extensions.m
//  ObjCTest
//
//  Created by Vanush Grigoryan on 11/7/20.
//

#import <Foundation/Foundation.h>

@implementation NSPointerArray (Extensions)

-(NSUInteger) indexOfObject: (id) object {
    NSUInteger index = 0;
    for(id e in self) {
        if (e == object) {
            return index;
        }
        ++index;
    }
    return NSNotFound;
}

-(NSUInteger) indexOfObjectPassingTest: (BOOL (^)(id object)) predicate {
    NSUInteger index = 0;
    for(id e in self) {
        if (predicate(e)) {
            return index;
        }
        ++index;
    }
    return NSNotFound;
}

@end
