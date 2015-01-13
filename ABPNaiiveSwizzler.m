// Copyright (c) 2014 Dmitry Rodionov
// https://github.com/rodionovd/ABetterPlaceForTweetbot
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.
//
#import "ABPNaiiveSwizzler.h"

@implementation ABPNaiiveSwizzler

+ (void)swizzleMethods: (NSDictionary *)methods
              provider: (Class)provider
           usingPrefix: (NSString *)prefix
{
	[methods enumerateKeysAndObjectsUsingBlock: ^(NSString *class_name, NSArray *selectors, BOOL *stop1) {
		[selectors enumerateObjectsUsingBlock: ^(NSString *selector_name, NSUInteger index, BOOL *stop2) {

			Class class = NSClassFromString(class_name);
			BOOL keep_it = YES;
			id meta_or_not = provider;

			if ([selector_name hasPrefix: @"+"]) {
				selector_name = [selector_name substringFromIndex: 1];
				meta_or_not = objc_getMetaClass(class_getName(meta_or_not));
				class = objc_getMetaClass(class_getName(class));
			}

			SEL selector = NSSelectorFromString(selector_name);
			Method originalMethod = class_getInstanceMethod(class, selector);

			Method newMethod = class_getInstanceMethod(meta_or_not, selector);
			if (!newMethod) {
				return;
			}

			IMP new_imp = method_getImplementation(newMethod);
			const char* method_type_encoding = method_getTypeEncoding(originalMethod);

			if ( ! class_addMethod(class, selector, new_imp, method_type_encoding) && originalMethod) {
				IMP original_imp = class_replaceMethod(class, selector, new_imp, method_type_encoding);

				if (keep_it) {
					NSString *backup_sel_string = [NSString stringWithFormat:
						@"%@_%@", prefix ?: NSStringFromClass(self), selector_name];
					class_addMethod(class, NSSelectorFromString(backup_sel_string), original_imp, method_type_encoding);
				}
			}
		}];
	}];
}


@end
