//
//  OpenCVWrapper.m
//  ASLApp
//
//  Created by Héctor J. Vázquez on 7/6/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/objdetect.hpp>
#import "opencv2/imgproc/imgproc.hpp"
#import <QuartzCore/QuartzCore.h>
#import <ChameleonFramework/Chameleon.h>



using namespace std;
using namespace cv;

@implementation OpenCVWrapper

//Here we can use C++ code!!!

+(cv::Mat)_cvMatfromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
  
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  
  void* bufferAddress;
  size_t width;
  size_t height;
  size_t bytesPerRow;
  int format_opencv;
  
  OSType format = CVPixelBufferGetPixelFormatType(imageBuffer);
  // Only format taken by iPhone 6
  if (format == kCVPixelFormatType_32BGRA){
    
    format_opencv = CV_8UC4;
    bufferAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    width = CVPixelBufferGetWidth(imageBuffer);
    height = CVPixelBufferGetHeight(imageBuffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
  }

  cv::Mat image((int)height, (int)width, format_opencv, bufferAddress, bytesPerRow);
  cv::Mat copy_image = image.clone();
  cv::Mat gray_image;
  cv::cvtColor(copy_image, gray_image, cv::COLOR_RGB2GRAY);
  cv::equalizeHist(gray_image, gray_image);
  transpose(gray_image, gray_image);
  flip(gray_image, gray_image, 1);

  
  CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

  return gray_image;

}

//for debugging purposes, will delete after
+(UIImage *)UIImageFromBuffer:(CMSampleBufferRef)buffer
{
  cv::Mat cvImage = [OpenCVWrapper _cvMatfromSampleBuffer:buffer];
  UIImage *image =[OpenCVWrapper UIImageFromCVMat: cvImage];
  return image;
}

//for debugging purposes, will delete after
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
  NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  CGColorSpaceRef colorSpace;
  if (cvMat.elemSize() == 1) {
    colorSpace = CGColorSpaceCreateDeviceGray();
  } else {
    colorSpace = CGColorSpaceCreateDeviceRGB();
  }
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  CGImageRef imageRef = CGImageCreate(
                                      cvMat.cols,  //width
                                      cvMat.rows,                                 //height
                                      8,                                          //bits per component
                                      8 * cvMat.elemSize(),                       //bits per pixel
                                      cvMat.step[0],                            //bytesPerRow
                                      colorSpace,                                 //colorspace
                                      kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                      provider,                                   //CGDataProviderRef
                                      NULL,                                       //decode
                                      false,                                      //should interpolate
                                      kCGRenderingIntentDefault                   
                                      );
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return finalImage;
}

+(CGRect)detectSampleBufferObject: (CMSampleBufferRef)image model:(NSString *)model {
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:model ofType:@"xml"];
  std::string stringPath = std::string([filePath UTF8String]);
  
  String cascade_name = stringPath;
  CascadeClassifier cascade_model;
  
  if( !cascade_model.load( cascade_name ) ){ printf("--(!)Error loading cascade\n");}
  Mat frame_gray;
  
  try{
    cv::Mat cvImage = [OpenCVWrapper _cvMatfromSampleBuffer:image]; //returns gray CVMat image
    std::vector<cv::Rect> matches;
    cascade_model.detectMultiScale( cvImage, matches, 1.1, 2, CV_HAAR_DO_ROUGH_SEARCH, cvSize(70, 70), cvSize(1000,1000));
    printf("%zd matches found.\n", matches.size());
  
  NSLog(@"model %@", model);

    if (matches.size() > 0){
      //find biggest match
      CGRect biggestMatch = [ OpenCVWrapper _findBiggestRect:matches];
      return biggestMatch;
    }else{
      return CGRectMake(0, 0, 0, 0);
    }
    
  }catch(exception* e){
    printf("no image found");
  }
  return CGRectMake(0,0,0,0);

}

+(CGRect)_findBiggestRect:(const std::vector<cv::Rect>&)matches{
  cv:: Rect biggestRect(0,0,0,0);
  CGRect finalRect = CGRectMake(0,0,0,0);
  
  for ( size_t i = 0; i < matches.size(); i++ )
  {
    cv::Rect rect = matches[i];
    if(rect.area() > biggestRect.area()) {
      biggestRect = rect;
    }
    finalRect.origin.x = biggestRect.x;
    finalRect.origin.y = biggestRect.y;
    finalRect.size.width = biggestRect.width;
    finalRect.size.height = biggestRect.height;
  }
  return finalRect;
}


@end