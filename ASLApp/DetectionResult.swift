//
//  DetectionResult.swift
//  ASLApp
//
//  Created by Olivia Koshy on 7/29/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

import UIKit


class DetectionResult: NSObject {
  
  var rect: CGRect?
  var text: String?
  var modelName: String?
  var detectionValue: Int?
  var cleanValue: Int?
  
  
  
  init(modelName: String){
    self.modelName = modelName
    self.detectionValue = 0
    self.cleanValue = 0
    self.rect = CGRect(x: 0, y: 0, width: 0, height: 0)
    self.text = ""
    
  }
  
  
  

}
