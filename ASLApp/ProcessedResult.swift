//
//  ProcessedResult.swift
//  ASLApp
//
//  Created by Héctor J. Vázquez on 7/29/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//



class ProcessedResult: NSObject {
  var text: String?
  var rect: CGRect?
  var image: UIImage?
  var model: String?
  var shouldBeDisplayed: Bool?
  
  override init() {
    text = ""
    rect = CGRect(x: 0,y: 0,width: 0,height: 0)
    model = ""
    shouldBeDisplayed = false
  }
  
  

}
