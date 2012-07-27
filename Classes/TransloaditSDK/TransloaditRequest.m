#import "TransloaditRequest.h"

@implementation TransloaditRequest
@synthesize params, response;

#pragma mark public

/**
 * Initializes the TransloaditRequest object w/ API credentials.
 *
 * @param  NSString  API Key (see: https://transloadit.com/accounts/credentials )
 * @param  NSString  API Secret (see: https://transloadit.com/accounts/credentials )
 *
 * @returns  id
 */
- (id)initWithCredentials:(NSString *)key secret:(NSString *)secretKey
{
	NSURL *serviceUrl = [NSURL URLWithString:@"http://api2.transloadit.com/assemblies?pretty=true"];
	[super initWithURL:serviceUrl];

	params = [[NSMutableDictionary alloc] init];
	[secret release];
	secret = [secretKey retain];

	NSMutableDictionary *auth = [[NSMutableDictionary alloc] init];
	[auth setObject:key forKey:@"key"];
	[params setObject:auth forKey:@"auth"];
	[auth release];

	return self;
}

/**
 * Adds a file (from local path) to the transloadit request.
 *
 * @param  NSString  File path
 * @param  NSString  File name (eg: @"myFile.wav")
 * @param  NSString  MIME type (eg: @"audio/wav")
 *
 * @returns  void
 */
- (void)addRawFile:(NSString *)path withFileName:(NSString *)filename addContentType:(NSString *)type
{
    uploads++;
    NSString *field = [NSString stringWithFormat:@"upload_%i", uploads];
    [self setFile:path withFileName:filename andContentType:type forKey:field];
}

/**
 * Adds raw data to transloadit request.
 *
 * @param  NSData  Asset data
 * @param  NSString  File name (eg: @"myFile.mov")
 * @param  NSString  MIME type (eg: @"video/quicktime")
 *
 * @returns  void
 */
- (void)addRawData:(NSData *)data withFileName:(NSString *)filename addContentType:(NSString *)type
{
    uploads++;
    NSString *field = [NSString stringWithFormat:@"upload_%i", uploads];
    [self setData:data withFileName:filename andContentType:type forKey:field];
}

/**
 * Adds file from a UIImagePickerController to transloadit request.
 *
 * @param  NSDictionary  Asset
 *
 * @returns  void
 */
- (void)addPickedFile:(NSDictionary *)info
{
	uploads++;
	NSString *field = [NSString stringWithFormat:@"upload_%i", uploads];
	[self addPickedFile:info forField:field];
}

/**
 * Adds file from a UIImagePickerController to transloadit request w/ field.
 *
 * @param  NSDictionary  Asset
 * @param  NSString  Field
 *
 * @returns  void
 */
- (void)addPickedFile:(NSDictionary *)info forField:(NSString *)field;
{
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

	if ([mediaType isEqualToString:@"public.image"]) {
		backgroundTasks++;
		NSMutableDictionary *file = [[NSMutableDictionary alloc] init];
		[file setObject:info forKey:@"info"];
		[file setObject:field forKey:@"field"];
		[self performSelectorInBackground:@selector(saveImageToDisk:) withObject:file];
	} else if ([mediaType isEqualToString:@"public.movie"]) {
		NSURL *fileUrl = [info valueForKey:UIImagePickerControllerMediaURL];
		NSString *filePath = [fileUrl path];
		[self setFile:filePath withFileName:@"iphone_video.mov" andContentType: @"video/quicktime" forKey:field];
	}
}

/**
 * Starts asynchronous request.
 *
 * @returns  void
 */
- (void)startAsynchronous
{
	readyToStart = YES;
	if (backgroundTasks) {
		return;
	}

	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"yyyy-MM-dd HH:mm-ss 'GMT'"];

	NSDate *localExpires = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60];
	NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
	NSTimeInterval gmtTimeInterval = [localExpires timeIntervalSinceReferenceDate] - timeZoneOffset;
	NSDate *gmtExpires = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];

	[[params objectForKey:@"auth"] setObject:[format stringFromDate:gmtExpires] forKey:@"expires"];
	[localExpires release];
	[format release];

	NSString *paramsField = [params JSONString];
	NSString *signatureField = [TransloaditRequest stringWithHexBytes:[TransloaditRequest hmacSha1withKey:secret forString:paramsField]];
	
	[self setPostValue:paramsField forKey:@"params"];
	[self setPostValue:signatureField forKey:@"signature"];
    
	[super startAsynchronous];
}

/**
 * Updates the template ID.
 *
 * @param  NSString  Template id (see: https://transloadit.com/templates)
 *
 * @returns  void
 */
- (void)setTemplateId:(NSString *)templateId
{
	[params setObject:templateId forKey:@"template_id"];
}

/**
 * Checks response the existence of an error.
 *
 * @returns  BOOL
 */
- (bool)hadError
{
	if ([response objectForKey:@"error"]) {
		return true;
	}
	return false;
}

#pragma mark private

- (void)requestFinished
{
	response = [[self responseString] objectFromJSONString];
	[response retain];
    
	[super requestFinished];
}

- (void)saveImageToDisk:(NSMutableDictionary *)file
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *tmpFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"transloadfile" stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]]];	
	UIImage *image = [[file objectForKey:@"info"] objectForKey:@"UIImagePickerControllerOriginalImage"];
	[UIImageJPEGRepresentation(image, 0.9f) writeToFile:tmpFile atomically:YES];
	[file setObject:tmpFile forKey:@"path"];
	[self performSelectorOnMainThread:@selector(addImageFromDisk:) withObject:file waitUntilDone:NO];

	[pool release];
}

- (void)addImageFromDisk:(NSMutableDictionary *)file
{
	[self setFile:[file objectForKey:@"path"] withFileName:@"iphone_image.jpg" andContentType: @"image/jpeg" forKey:[file objectForKey:@"field"]];
	backgroundTasks--;
	if (readyToStart) {
		[self startAsynchronous];
	}
	[file release];
}

// from: http://stackoverflow.com/questions/476455/is-there-a-library-for-iphone-to-work-with-hmac-sha-1-encoding
+ (NSData *)hmacSha1withKey:(NSString *)key forString:(NSString *)string
{
	NSData *clearTextData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	
	CCHmacContext hmacContext;
	CCHmacInit(&hmacContext, kCCHmacAlgSHA1, keyData.bytes, keyData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
	
	return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

// from: http://notes.stripsapp.com/nsdata-to-nsstring-as-hex-bytes/
+ (NSString *)stringWithHexBytes:(NSData *)data
{
	static const char hexdigits[] = "0123456789abcdef";
	const size_t numBytes = [data length];
	const unsigned char* bytes = [data bytes];
	char *strbuf = (char *)malloc(numBytes * 2 + 1);
	char *hex = strbuf;
	NSString *hexBytes = nil;
	
	for (int i = 0; i<numBytes; ++i) {
		const unsigned char c = *bytes++;
		*hex++ = hexdigits[(c >> 4) & 0xF];
		*hex++ = hexdigits[(c ) & 0xF];
	}
	*hex = 0;
	hexBytes = [NSString stringWithUTF8String:strbuf];
	free(strbuf);
	return hexBytes;
}

- (void)dealloc
{
	[params release];
	[response release];
	[secret release];

    [super dealloc];
}

@end