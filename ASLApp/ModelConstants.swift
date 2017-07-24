//
//  ModelConstants.swift
//  ASLApp
//
//  Created by Olivia Koshy on 7/29/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

import Foundation

let models: [String] =
  ["fist",                              //model[0]
   "palm",                              //model[1]
   "I_Model_500p_1000n_s19_GRAYSCALE",      //model[2]
   "O_Model_1000p_2000n_GRAYSCALE",     //model[3]
   "L_Model_1000p_2000n_GRAYSCALE",      //model[4]
  "V_IncModel_500p_1000n_S15"] //model[5]

//frame threshold for letter image to be displayed
let detectionThreshold = Tweaks.assign(Tweaks.detectionThreshold)

//frame threshold for letter image to be removed
let cleanThreshold = Tweaks.assign(Tweaks.cleanThreshold)

let modelsToLetters: [String : UIImage] =
  [models[0]: UIImage(named: "At")!,
   models[1]: UIImage(named: "Bt")!,
   models[2]: UIImage(named: "It")!,
   models[3]: UIImage(named: "Ot")!,
   models[4]: UIImage(named: "Lt")!,
   models[5]: UIImage(named: "Vt")!]



let tempDictionary: [String : Int] =
  [models[0]: 0,
   models[1]: 0,
   models[2]: 0,
   models[3]: 0,
    models[4]: 0,
    models[5]: 0]


var modelsToAlpha: [String : String] = [
     models[0]: "A",
     models[1]: "B",
     models[2]: "I",
     models[3]: "O",
     models[4]: "L",
     models[5]: "V"]

