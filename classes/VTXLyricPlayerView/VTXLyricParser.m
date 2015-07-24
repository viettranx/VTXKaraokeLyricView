//
//  VTXLyricParser.m
//  
//
//  Created by Tran Viet on 7/24/15.
//  Thanks dphans for the great idea parser
//  https://github.com/dphans/DemoLrcParse/blob/master/DemoLrcParse/DPBasicLRCParser.swift
//

#import "VTXLyricParser.h"
#import "VTXLyric.h"

@interface VTXLyricParser() {
    NSString *lrc_content;
}

@end

@implementation VTXLyricParser

- (VTXLyric *)lyricFromLocalPathFileName:(NSString *)LRC_FileName {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:LRC_FileName ofType:@"lrc"];
    
    lrc_content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self lyricFromLRCString:lrc_content];
}

- (VTXLyric *)lyricFromLRCString:(NSString *)lrcString {
    NSLog(@"need to implement at subclass");
    return nil;
}

- (CGFloat)doubleFromString:(NSString *)str {
    
    CGFloat result = 0;
    NSArray *timeParts = [str componentsSeparatedByString:@":"];
    
    if ([timeParts count] > 1) {
        CGFloat min = [[timeParts objectAtIndex:0] doubleValue];
        CGFloat sec = [[timeParts objectAtIndex:1] doubleValue];
        result = min*60 + sec;
    }
    
    return result;
}
@end


@implementation VTXBasicLyricParser

- (VTXLyric *)lyricFromLRCString:(NSString *)lrcString {
    VTXLyric *lyric = [[VTXLyric alloc] init];
    
    NSArray *lyricArr = [lrcString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableDictionary *lyricContent = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < [lyricArr count] ; i++) {
        NSString *phrase = [lyricArr objectAtIndex:i];
        
        if ([phrase hasPrefix:@"["]) {
            // Lyric info
            if ([phrase hasPrefix:@"[ti:"] || [phrase hasPrefix:@"[ar:"] || [phrase hasPrefix:@"[al:"] || [phrase hasPrefix:@"[by:"]) {
                
                NSString *text = [phrase substringWithRange:NSMakeRange(4, [phrase length] - 5)];
                
                if ([phrase hasPrefix:@"[ti:"]) {
                    lyric.title = text;
                }
                else if([phrase hasPrefix:@"[ar:"]) {
                    lyric.singer = text;
                }
                else if([phrase hasPrefix:@"[al:"]) {
                    lyric.album = text;
                }
                else if([phrase hasPrefix:@"[by:"]) {
                    lyric.composer = text;
                }
                
                // Lyric content
            } else {
                NSArray *textParts = [phrase componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                NSString *lyricText = textParts[2];
                CGFloat keyTime = [self doubleFromString:textParts[1]];
                [lyricContent setObject:lyricText forKey: [NSString stringWithFormat:@"%.3f", keyTime]];
            }
        }
    }
    
    lyric.content = lyricContent;
    return lyric;
}
@end
