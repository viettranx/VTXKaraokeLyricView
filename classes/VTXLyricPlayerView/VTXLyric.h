//
//  VTXLyric.h
//  
//
//  Created by Tran Viet on 7/24/15.
//
//

#import <UIKit/UIKit.h>

@interface VTXLyric : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *singer;
@property (strong, nonatomic) NSString *composer;
@property (strong, nonatomic) NSString *album;
//@property (nonatomic) CGFloat length;

@property (strong, nonatomic) NSDictionary *content;

- (instancetype)initWithTitle:(NSString *)title
                       singer:(NSString *)singer
                     composer:(NSString *)composer
                        album:(NSString *)album;

@end
