/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiFile.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiBlob.h"
#import "JSON/SBJson.h"
#import "JSON/SBJsonParser.h"
#import <QuartzCore/CALayer.h>
#import "TransloaditRequest.h"

@interface TiTransloaditClientProxy : TiProxy <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	NSString *templateId;
	NSString *authSecret;
	NSDictionary *paramDict;
	TransloaditRequest *transload;
	KrollCallback *successCallback;
    KrollCallback *errorCallback;
    KrollCallback *cancelCallback;
	KrollCallback *progressCallback;
}

@end
