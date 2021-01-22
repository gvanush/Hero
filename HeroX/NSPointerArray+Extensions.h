//
//  NSPointerArray+Extensions.h
//  ObjCTest
//
//  Created by Vanush Grigoryan on 11/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPointerArray (Extensions)

-(NSUInteger) indexOfObject: (id) object;
-(NSUInteger) indexOfObjectPassingTest: (BOOL (^)(id object)) predicate;

@end

NS_ASSUME_NONNULL_END
