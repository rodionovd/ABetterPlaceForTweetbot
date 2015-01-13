// Copyright (c) 2014 Dmitry Rodionov
// https://github.com/rodionovd/ABetterPlaceForTweetbot
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.
//
#import <Cocoa/Cocoa.h>
#include <objc/runtime.h>

#import "ABPTweetScore.h"
#import "ABPNaiiveSwizzler.h"

inline id runtime_getIvarObject(id <NSObject> object, const char *ivar_name)
{
    Ivar ivar = class_getInstanceVariable(object.class, ivar_name);
    return (ivar == nil) ? nil : object_getIvar(object, ivar);
}

@implementation RDTweetbotABPPlugin: NSObject

+ (void)load
{
	@autoreleasepool {
		// Remove already downloaded inappropriate tweets for all accounts
		NSArray *accounts = [NSClassFromString(@"PTHTweetbotAccount") _accounts];
		[accounts enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
			id user = [obj currentUser];
			id timelineCursor = [user homeTimelineCursor];
			NSArray *tweets = [timelineCursor items];
			[tweets enumerateObjectsUsingBlock: ^(id status, NSUInteger idx, BOOL *stop) {
				[RDTweetbotABPPlugin hideTweetIfNeeded: status];
			}];
		}];

		// Hook any future updates as well
		NSDictionary *todo = @{
			@"PTHTweetbotStatus" : @[@"_updateFromDictionary:", @"updateFromDictionary:"]
		};
		[ABPNaiiveSwizzler swizzleMethods: todo provider: self usingPrefix: @"rd_abp"];
	}
}


#pragma mark - Swizzled methods of PTHTweetbotStatus

- (void)_updateFromDictionary: (id)dictionary
{
	[self rd_abp__updateFromDictionary: dictionary];
	[RDTweetbotABPPlugin hideTweetIfNeeded: self];
}

- (void)updateFromDictionary: (id)dictionary
{
	[self rd_abp_updateFromDictionary: dictionary];
	[RDTweetbotABPPlugin hideTweetIfNeeded: self];
}

#pragma mark - Misc

+ (void)hideTweetIfNeeded: (id)tweet
{
	NSString *text = [tweet text];
	NSInteger score = [ABPTweetScore scoreForTweet: text];
	if (score <= 0) {
		[RDTweetbotABPPlugin removeTweet: tweet];
	}
}

+ (void)removeTweet: (id)tweet
{
	id acc = runtime_getIvarObject(tweet, "_account");
	id user = [acc currentUser];
	id timeline = [user homeTimelineCursor];
	[timeline removeItem: tweet];
	id favcursor = [user favoritesCursor];
	[favcursor removeItem: tweet];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"PTHTweetbotStatusWasDestroyed"
	                                                    object: tweet];
}

@end
