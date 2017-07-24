//
//  OpenCVWrapper.h
//  ASLApp
//
//  Created by Héctor J. Vázquez on 7/6/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


@interface OpenCVWrapper : NSObject
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

+(CGRect)detectSampleBufferObject: (CMSampleBufferRef)image model:(NSString *)model;


@end
