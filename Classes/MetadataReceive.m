//
//  MetadataReceive.m
//  aurioTouch2
//
//  Created by Littlebox222 on 13-11-22.
//
//

#import "MetadataReceive.h"

@implementation MetadataReceive

@synthesize code = _code;
@synthesize sha1 = _sha1;
@synthesize type = _type;
@synthesize ctime = _ctime;
@synthesize content = _content;


static NSDictionary *kSharedFileExtNameDictionary = nil;


+ (NSDictionary *)sharedFileExtNameDictionary {
    
    if (kSharedFileExtNameDictionary == nil) {
        
        kSharedFileExtNameDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FileExt" ofType:@"plist"]];
    }
    
    return kSharedFileExtNameDictionary;
}


+ (NSString *)humanReadableSize:(unsigned long long)length {
	
	NSArray *filesizename = [NSArray arrayWithObjects:@" Bytes", @" KB", @" MB", @" GB", @" TB", @" PB", @" EB", @" ZB", @" YB", nil];
	
	if (length > 0) {
		
		int i = floor(log2(length) / 10);
        if (i > 8) i = 8;
		double s = length / pow(1024, i);
        
		return [NSString stringWithFormat:@"%.2f%@", s, [filesizename objectAtIndex:i]];
	}
	
	return @"0 Bytes";
}

- (NSURL *)fileURL {

    if ([self.type isEqualToString:@"file"] && self.content != nil && [self.content isKindOfClass:[NSString class]]) {
        
        return [NSURL URLWithString:self.content];
    }
    
    return nil;
}

- (NSString *)filename {

    if (self.fileURL) {
        
        NSString *query = [self.fileURL query];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        NSArray *paramsArray = [query componentsSeparatedByString:@"&"];
        
        for (NSString *paramStr in paramsArray) {
            
            NSArray *paramArray = [paramStr componentsSeparatedByString:@"="];
            if ([paramArray count] != 2) continue;
            [dict setObject:[[[paramArray objectAtIndex:1] stringByDecodingURLFormat] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:[paramArray objectAtIndex:0]];
            
        }
        
        return [dict objectForKey:@"fn"];
        
    }
    
    return nil;
}

- (NSString *)size {

    return [MetadataReceive humanReadableSize:self.totalBytes];
}

- (NSString *)reader {
    
    NSString *reader = nil;
    
    NSArray *nameItems = [self.filename componentsSeparatedByString:@"."];
    
    if ([nameItems count] > 1) {
        
        NSString *extName = [[nameItems lastObject] lowercaseString];
        
        if ([[[MetadataReceive sharedFileExtNameDictionary] objectForKey:extName] isKindOfClass:[NSDictionary class]]) {
            
            reader = [[[MetadataReceive sharedFileExtNameDictionary] objectForKey:extName] objectForKey:@"reader"];
            
        } else {
            
            reader = [[[MetadataReceive sharedFileExtNameDictionary] objectForKey:@"other"] objectForKey:@"reader"];
        }
        
    } else {
        
        reader = [[[MetadataReceive sharedFileExtNameDictionary] objectForKey:@"other"] objectForKey:@"reader"];
    }
    
    return reader;
}


- (void)dealloc {
    
    [_code release];
    [_sha1 release];
    [_type release];
    [_ctime release];
    [_content release];
    
    [super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    
    if (self = [super init]) {
        
        @try {
            
            self.code = [NSString stringWithFormat:@"%@", [dict objectForKey:@"code"]];
            self.sha1 = [NSString stringWithFormat:@"%@", [dict objectForKey:@"sha1"]];
            self.type = [NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]];
            self.content = [NSString stringWithFormat:@"%@", [dict objectForKey:@"content"]];
            self.totalBytes = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"size"]] longLongValue];
            self.ctime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"ctime"] doubleValue]];
        
        } @catch (NSException *exception) {
            
            NSLog(@"%@", exception);
        }
    }
    
    return self;
}

@end