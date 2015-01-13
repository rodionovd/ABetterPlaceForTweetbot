// Copyright (c) 2014 Dmitry Rodionov
// https://github.com/rodionovd/ABetterPlaceForTweetbot
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ABPNaiiveSwizzler : NSObject

+ (void)swizzleMethods: (NSDictionary *)methods
              provider: (Class)provider
           usingPrefix: (NSString *)prefix;

@end;
