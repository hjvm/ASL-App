//
//  HomeViewController.swift
//  ASLApp
//
//  Created by Olivia Koshy on 7/5/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import SwiftTweaks
import EasyAnimation


import ChameleonFramework

class HomeViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
  
  //CameraView variables
  //var session: AVCaptureSession?
  //var stillImageOutput: AVCaptureStillImageOutput?
  //var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var processor: FrameProcessor?
  var dataOutput: AVCaptureVideoDataOutput!
  var processData: Bool = false
  var captureDevice : AVCaptureDevice?
  var videoURL: URL?
  var speechSynthesizer : AVSpeechSynthesizer = AVSpeechSynthesizer()
  var rate: Float!
  var pitch: Float!
  var volume: Float!
  var emptyFrames: Int = 0
  var hideTextThreshold = Tweaks.assign(Tweaks.hideTextThreshold)
  var showDirectionThreshold = Tweaks.assign(Tweaks.showInitialThreshold)
  @IBOutlet weak var rectImage: UIImageView!
  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var clearButton: UIButton!
  @IBOutlet weak var readButton: UIButton!
  @IBOutlet weak var floatBoxView: UIView!
  @IBOutlet weak var notDetectingView: UIView!
  


  
    var items: [(icon: String, color: UIColor, text: String)] = [
        ("icon_camera", UIColor(red:0.19, green:0.57, blue:1, alpha:1), "record"),            //button 0
        ("icon_upload1", UIColor(red:0.22, green:0.74, blue:0, alpha:1), "upload"),            //button 1
        ("icon_search", UIColor(red:0.96, green:0.23, blue:0.21, alpha:1), "bell"),           //button 2
        ("settings-btn", UIColor(red:0.51, green:0.15, blue:1, alpha:1), "setting"),          //button 3
        ("nearby-btn", UIColor(red:1, green:0.39, blue:0, alpha:1), "nearby"),                //button 4
        ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    notDetectingView.isHidden = false
    floatBoxView.isHidden = true
    self.view.layer.borderColor = UIColor(colorLiteralRed: 67, green: 205, blue: 200, alpha: 0.75).cgColor
    floatBoxView.layer.borderColor = UIColor(colorLiteralRed: 67, green: 205, blue: 200, alpha: 0.75).cgColor
    textView.isHidden = true
    rectImage.isHidden = true
    
    //set up buttons:
    readButton.layer.cornerRadius = 0.5 * readButton.bounds.size.width
    readButton.layer.borderColor = UIColor.flatGrayColorDark().cgColor as CGColorRef
    textView.layer.cornerRadius = 10
    textView.tag = 0
    
    let devices = AVCaptureDevice.devices()
    for device in devices {
      if (device.hasMediaType(AVMediaTypeVideo)) {
        if(device.position == AVCaptureDevicePosition.back){
          captureDevice = device as? AVCaptureDevice
        }
      }
    }
    if captureDevice != nil {
      setupCameraSession()
    }
    
    processor = FrameProcessor()
    self.speak("Welcome to Sign Me Up")
    self.speak("Point me towards ASL Alphabets!")

    didTakePhoto()
  
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if captureDevice != nil {
      previewView.layer.addSublayer(previewLayer)
      //view.addSubview(textView)
      view.layer.addSublayer(rectImage.layer)
      
      
      cameraSession.startRunning()
      rectImage.isHidden = true
      previewView.layer.borderColor = UIColor(gradientStyle:UIGradientStyle.radial, withFrame:previewView.bounds, andColors:[UIColor.flatBlack(), UIColor.flatWhite()]).cgColor
      previewView.layer.borderWidth = 3
    }
  }

  lazy var cameraSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = AVCaptureSessionPresetMedium
    return session
  }()
  
  lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let preview = AVCaptureVideoPreviewLayer(session: self.cameraSession)
    preview.bounds = CGRect(x: 0, y: 0, width: self.previewView.bounds.width, height: self.previewView.bounds.height)
    preview.position = CGPoint(x: self.previewView.bounds.midX, y: self.previewView.bounds.midY)
    preview.videoGravity = AVLayerVideoGravityResize
    preview.connection.videoOrientation = AVCaptureVideoOrientation.portrait
    return preview
  }()
  
  func setupCameraSession() {
    do {
      try cameraSession.addInput(AVCaptureDeviceInput(device: captureDevice))
    } catch let error as NSError {
      print(error)
      return
    }
    do {
      var finalFormat = AVCaptureDeviceFormat()
      var maxFps: Double = 0
      for vFormat in captureDevice!.formats {
        var ranges = vFormat.videoSupportedFrameRateRanges as!  [AVFrameRateRange]
        let frameRates = ranges[0]
        print("frameRates: ", frameRates)
        /*
         "frameRates.maxFrameRate >= maxFps" select the video format
         desired with the highest resolution available, because
         the camera formats are ordered; else
         "frameRates.maxFrameRate > maxFps" select the first
         format available with the desired fps
         */
        if frameRates.maxFrameRate >= maxFps && frameRates.maxFrameRate <= maxFps {
          maxFps = frameRates.maxFrameRate
          finalFormat = vFormat as! AVCaptureDeviceFormat
        }
      }
      if maxFps != 0 {
        try captureDevice!.lockForConfiguration()
        captureDevice!.activeFormat = finalFormat
        captureDevice!.activeVideoMinFrameDuration = CMTimeMake(1, Int32(self.processor!.fps))
        captureDevice!.activeVideoMaxFrameDuration = CMTimeMake(1, Int32(self.processor!.fps))
        captureDevice!.focusMode = AVCaptureFocusMode.autoFocus
        captureDevice!.unlockForConfiguration()
      }
    }
    catch {
      print("Something went wrong")
    }
    self.dataOutput = AVCaptureVideoDataOutput()
    dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as AnyObject) as! NSObject : Int(kCVPixelFormatType_32BGRA)]
    dataOutput.alwaysDiscardsLateVideoFrames = true
    if (cameraSession.canAddOutput(dataOutput) == true ) {
      cameraSession.addOutput(dataOutput)
    }
    cameraSession.commitConfiguration()
    let queue = DispatchQueue(label: "com.invasivecode.videoQueue", attributes: [])
    dataOutput.setSampleBufferDelegate(self, queue: queue)
  }
  
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    if processData {
      
      let priority = DispatchQueue.GlobalQueuePriority.default
      DispatchQueue.global(priority: priority).async {
        //let image = self.processor!.imageFromSampleBuffer(sampleBuffer)
        //self.processor?.frameProcessor(image!, textView: self.textView)
        self.processor?.bufferProcessor(sampleBuffer, completionHandler: {(bestResult) -> Void in
          self.updateDisplay(bestResult)
        })
      }
    }
    else {
      //Not processing camera's output
    }
    
  }
  
  func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    //all the frames that are droppeds
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func uploadAction() {
    let secondVC = VideoUpload(nibName: "VideoUpload", bundle: nil)
    self.present(secondVC, animated: true, completion: nil)
  }
  
 func didTakePhoto() {
    if processData {
      processData = false
      print("stopped processing frames")
        items[0] = ("icon_camera", UIColor(red:0.19, green:0.57, blue:1, alpha:1), "record")
        
    }else {
      self.speak("Now Detecting")
      processData = true
      print("starting to process frames")
      items[0] = ("icon_stop-camera", UIColor(red:0.19, green:0.57, blue:1, alpha:1), "stop")

    }
  }

  func speak(_ text: String) {
    if !speechSynthesizer.isSpeaking {
      let textParagraphs = text.components(separatedBy: "\n")
      print(textParagraphs)
      
      for pieceOfText in textParagraphs {
        print(pieceOfText)
        let speechUtterance = AVSpeechUtterance(string: pieceOfText)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.pitchMultiplier = 1.0
        speechUtterance.volume = 1.0
        speechUtterance.postUtteranceDelay = 0.005
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")

        speechSynthesizer.speak(speechUtterance)
      }
    }
  }
    
    @IBAction func clearButtonPressed(_ sender: AnyObject) {
        textView.text = ""
        textView.isHidden = true
      
    }
    
    
    @IBAction func readButtonPressed(_ sender: AnyObject) {
      print("speaking \(textView.text)")
        self.speak(textView.text)
    }
  
  
  func isDetecting() {
    print("isDetecting")
    floatBoxView.isHidden = textView.isHidden
    notDetectingView.isHidden = !textView.isHidden
    
  
  }
  
  func updateDisplay(_ displayResult: ProcessedResult){
    
    if (displayResult.shouldBeDisplayed!) {
      self.emptyFrames = 0
      //textView
      self.floatBoxView.isHidden = false
      self.textView.isHidden = false
      if !(textView.text.hasSuffix(displayResult.text!)){
        self.speak(displayResult.text!)
        self.textView.text = self.textView.text + displayResult.text!
      }
      
      //rectImage (with animation)
      self.rectImage.isHidden = false
      self.rectImage.image = modelsToLetters[displayResult.model!]
      
      UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { self.rectImage.layer.frame = displayResult.rect!}, completion: nil)
      
      
      //notDetectingView
      self.notDetectingView.isHidden = true
      
    }else{
      
      self.emptyFrames+=1
      
      
      if self.emptyFrames > hideTextThreshold {
      //rectImage
      self.rectImage.isHidden = true
      }
      
      if self.emptyFrames > showDirectionThreshold {
      //notDetectingView
      self.textView.isHidden = true
      self.floatBoxView.isHidden = true
      self.emptyFrames = 0
      self.notDetectingView.isHidden = false
      }
    }
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
