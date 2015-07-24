//
//  VTXLyricParser.h
//  
//
//  Created by Tran Viet on 7/24/15.
//
//

#import "VTXLyric.h"
@class VTXLyric;

@interface VTXLyricParser : NSObject
- (VTXLyric *)lyricFromLocalPathFileName:(NSString *)LRC_FileName;
- (VTXLyric *)lyricFromLRCString:(NSString *)lrcString;
@end

@interface VTXBasicLyricParser : VTXLyricParser
@end