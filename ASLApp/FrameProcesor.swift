//
//  frameProcesor.swift
//  ASLApp
//
//  Created by Olivia Koshy on 7/20/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import SwiftTweaks
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FrameProcessor: NSObject {
  
  var framesReceived: Int = 0
  var view: UIView?
  var object: Int = 0
  var mainView : UIView?
  var fps = Tweaks.assign(Tweaks.fps)
  var frameThreshold = Tweaks.assign(Tweaks.frameThreshold)
  var detectionThreshold = Int32(Tweaks.assign(Tweaks.detectionThreshold))
  var modelsToRect: [String:CGRect] = [:]
  
  let model1 = DetectionResult(modelName: models[0])
  let model2 = DetectionResult(modelName: models[1])
  let model3 = DetectionResult(modelName: models[2])
  let model4 = DetectionResult(modelName: models[3])
  let model5 = DetectionResult(modelName: models[4])
  let model6 = DetectionResult(modelName: models[5])

  let detectionResultsArray: [DetectionResult]?
  
  
  override init(){
    self.detectionResultsArray = [model1, model2, model3, model4]
    
  }
  
  func bufferProcessor(_ buffer: CMSampleBuffer, completionHandler: (ProcessedResult) -> Void){
    //call CVWrapper functions the process images on backthread
    //This would either then delegate back to VC to call showBoxMethod on mainqueue
    var bestResult : ProcessedResult?
    self.framesReceived += 1
    
    if (self.framesReceived > frameThreshold) {
      self.framesReceived = 0
      
      let group: DispatchGroup = DispatchGroup()
      //async group 1:
      let parallelClassifierQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high)
      
      parallelClassifierQueue.async(group: group, execute: {() -> Void in
        // do calculations
        self.model1.rect = OpenCVWrapper.detectSampleBufferObject(buffer, model: models[0])
        self.model2.rect = OpenCVWrapper.detectSampleBufferObject(buffer, model: models[1])
        self.model3.rect = OpenCVWrapper.detectSampleBufferObject(buffer, model: models[2])
        self.model4.rect = OpenCVWrapper.detectSampleBufferObject(buffer, model: models[3])
        self.model5.rect = OpenCVWrapper.detectSampleBufferObject(buffer, model: models[4])
        self.model6.rect = OpenCVWrapper.detectSampleBufferObject(buffer, model: models[5])


      })
      
        group.notify(queue: DispatchQueue.main, execute: {() -> Void in
        self._updateThresholdValues()
        bestResult = self._selectBestMatch()
        completionHandler(bestResult!)
        
      })
    }
  }
  
  func _updateThresholdValues(){
    for model in detectionResultsArray!{
      if model.rect!.height > 0 {
        model.detectionValue!+=1
      }else{
        model.cleanValue!+=1
        if model.cleanValue > cleanThreshold {
          model.detectionValue = 0
          model.cleanValue = 0
        }
      }
      
    }
  }
  
  func _selectBestMatch() -> (ProcessedResult){
    var mostMatches = 0
    var clearValue = 0
    let bestResult = ProcessedResult()
    for model in detectionResultsArray!{
      if Int32(model.detectionValue!) > detectionThreshold {
        mostMatches = model.detectionValue!
        clearValue = model.cleanValue!
        bestResult.text = modelsToAlpha[model.modelName!]
        bestResult.rect = model.rect
        bestResult.model = model.modelName
      }
      if mostMatches == 0 && clearValue == 0 {
        bestResult.shouldBeDisplayed = false
      }else{
        bestResult.shouldBeDisplayed = true
      }
    }
    return bestResult
  }
  

  
  
  

}
  


