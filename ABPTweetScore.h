// Copyright (c) 2014 Dmitry Rodionov
// https://github.com/rodionovd/ABetterPlaceForTweetbot
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.
//
#import <Foundation/Foundation.h>

@interface ABPTweetScore: NSObject

+ (NSInteger)scoreForTweet: (NSString *)tweet;

@end
