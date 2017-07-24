//
//  Tweaks.swift
//  ASLApp
//
//  Created by Olivia Koshy on 7/25/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

import UIKit
import Foundation
import SwiftTweaks


public struct Tweaks: TweakLibraryType {
  public static let fps = Tweak<Int>("General", "Frames", "Frames Per Second", defaultValue: 60, min: 0, max:  600)
  public static let frameThreshold = Tweak<Int>("General", "Frames", "frameThreshold", 10)
  public static let detectionThreshold = Tweak<Int>("General", "Detection", "Detecting Sign Threshold", 7)
  public static let cleanThreshold = Tweak<Int>("General", "Detection", "Clean Threshold", 3)
  public static let buttonX = Tweak<CGFloat>("General", "UI", "Button X Coordinate", 175)
  public static let buttonY = Tweak<CGFloat>("General", "UI", "Button Y Cooridinate", 600)
  public static let hideTextThreshold = Tweak<Int>("General", "Processing", "Hide Text Threshold", 3)
  public static let showInitialThreshold = Tweak<Int>("General", "Processing", "Showing Initial Directions", 10)
  //public static let fps = Tweak("General", "Frames", "FPS", )
  
  
  
  public static let defaultStore: TweakStore = {
    let allTweaks: [TweakClusterType] = [frameThreshold, fps, detectionThreshold, buttonX, buttonY, hideTextThreshold, showInitialThreshold, cleanThreshold]
    
    let tweaksEnabled = true
    
    return TweakStore(
      tweaks: allTweaks,
      storeName: "tweaks",
      enabled: tweaksEnabled
    )
  }()
}


