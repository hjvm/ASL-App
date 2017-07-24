//
//  VideoUpload.swift
//  ASLApp
//
//  Created by Olivia Koshy on 7/13/16.
//  Copyright © 2016 Olivia Koshy. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MediaPlayer
import AVKit
import ChameleonFramework
import SwiftTweaks

class VideoUpload:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVPlayerViewControllerDelegate, UIVideoEditorControllerDelegate, UIPopoverPresentationControllerDelegate {
  
  
  @IBOutlet weak var videoView: UIView!
  let videoPicker = UIImagePickerController()
  var videoControl = AVPlayerViewController()
  var editControl = UIVideoEditorController()
  var videoLayer = AVPlayerLayer()
  var videoURL : URL?
  var videoPlayer = AVPlayer()
  var processor: FrameProcessor?
    
    
    
  @IBOutlet weak var textView: UITextView!
  
    
     func uploadVideo() {
    videoPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    videoPicker.delegate = self
    videoPicker.mediaTypes = ["kUTTypeMovie", "kUTTypeVideo",  "public.movie"]
    videoPicker.allowsEditing = true
    present(videoPicker, animated: true, completion: nil)
  }

  func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
    print("saved to \(editedVideoPath)")
    
    videoURL = URL(string: editedVideoPath)
    self.dismiss(animated: true, completion: nil)
  }
  
  func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
    print("editor cancelled")
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    videoControl.delegate = self
    
    }
  
  override func viewDidAppear(_ animated: Bool) {
    videoView.layer.addSublayer(videoLayer)
    
    //Set initial view background
    let colors:[UIColor] = [
        UIColor.flatRed(),
        UIColor.flatWhite()
    ]
    
    videoView.backgroundColor = GradientColor(.topToBottom, frame: videoView.frame, colors: colors)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let manager = FileManager.default
    guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
    guard let mediaType = info[UIImagePickerControllerMediaType] as? String else {return}
    guard let url = info[UIImagePickerControllerMediaURL] as? URL else {return}
    
    if mediaType == kUTTypeMovie as String || mediaType == kUTTypeVideo as String {
      let asset = AVAsset(url: url)
      let length = Float(asset.duration.value) / Float(asset.duration.timescale)
      print("video length: \(length) seconds")
      let start = info["_UIImagePickerControllerVideoEditingStart"] as? Float
      let end = info["_UIImagePickerControllerVideoEditingEnd"] as? Float
      var outputURL = documentDirectory.appendingPathComponent("output")
      
      do {
        try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
        outputURL = outputURL.appendingPathComponent("output.mp4")
      }catch let error {
        print(error)
      }
      
      //Remove existing file
      _ = try? manager.removeItem(at: outputURL)
      
      guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
      exportSession.outputURL = outputURL
      exportSession.outputFileType = AVFileTypeMPEG4
      print(exportSession.outputURL)
      videoURL = outputURL
      print("before", videoURL)
      let startTime = CMTime(seconds: Double(start ?? 0), preferredTimescale: 1000)
      let endTime = CMTime(seconds: Double(end ?? length), preferredTimescale: 1000)
      let timeRange = CMTimeRange(start: startTime, end: endTime)
      exportSession.timeRange = timeRange
      exportSession.exportAsynchronously{
        print(Thread.current)
        switch exportSession.status {
        case .completed:
          print("after", self.videoURL)
          print("exported at \(outputURL)")
          self.captureFrameFromVideo(self.videoURL!)
          DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
            self.videoPlayer = AVPlayer(url: self.videoURL!)
            self.videoLayer = AVPlayerLayer(player: self.videoPlayer)
            self.videoLayer.frame = self.videoView.frame
            self.videoLayer.bounds = CGRect(x: 0, y: 0, width: self.videoView.bounds.width, height: self.videoView.bounds.height)
            self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.videoLayer.position = CGPoint(x: self.videoView.bounds.midX, y: self.videoView.bounds.midY)
            self.videoPlayer.play()
          }
          
          
        case .failed:
          print("failed \(exportSession.error)")
          
        case .cancelled:
          print("cancelled \(exportSession.error)")
          
        default: break
        }
      }
    }
  }
  
func replayVideo() {
    print("recognized gesture")
    self.videoPlayer.seek(to: kCMTimeZero)
    self.captureFrameFromVideo(self.videoURL!)
    self.videoPlayer.play()
  }
  
  func captureFrameFromVideo(_ videoUR: URL) -> Void {
    let asset = AVURLAsset(url: videoURL!)
    let imgGenerator = AVAssetImageGenerator(asset: asset)
    imgGenerator.appliesPreferredTrackTransform = true
//    let time = NSValue(CMTime: CMTimeMakeWithSeconds(1, 10))
//    let time1 = NSValue(CMTime: CMTimeMakeWithSeconds(2, 10))
//    let time2 = NSValue(CMTime: CMTimeMakeWithSeconds(3, 60))
    var timeArray : [NSValue] = []
    
    let length = Float(asset.duration.value) / Float(asset.duration.timescale)
    let myLength: Int = Int(length)*13
    var i = 0
    while i < myLength{
      let time = CMTimeMakeWithSeconds(Float64(i), asset.duration.timescale)
      timeArray.append(NSValue(time: time))
      i = i + 1
    }
//
    imgGenerator.generateCGImagesAsynchronously(forTimes: timeArray) {
      (requestedTime: CMTime, frame: CGImage?, actualTime: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) in
      print("genrating frames", Thread.current)
      self.processor = FrameProcessor()

    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
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
