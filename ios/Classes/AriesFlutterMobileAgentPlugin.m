/*
  Copyright AyanWorks Technology Solutions Pvt. Ltd. All Rights Reserved.
  SPDX-License-Identifier: Apache-2.0
*/
#import "AriesFlutterMobileAgentPlugin.h"
#if __has_include(<AriesFlutterMobileAgent/AriesFlutterMobileAgent-Swift.h>)
#import <AriesFlutterMobileAgent/AriesFlutterMobileAgent-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "AriesFlutterMobileAgent-Swift.h"
#endif

@implementation AriesFlutterMobileAgentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAriesFlutterMobileAgentPlugin registerWithRegistrar:registrar];
}
@end
