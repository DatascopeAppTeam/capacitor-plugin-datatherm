//
//  DataFlirViewController.swift
//  Plugin
//
//  Created by Andrew Davies on 23/06/2023.
//  Copyright © 2023 Max Lynch. All rights reserved.
//

//
//  DataFlirViewController.swift
//  App
//
//  Created by Andrew Davies on 19/06/2023.
//

import Foundation
import UIKit
import ThermalSDK

class DataFlirViewController : UIViewController {
    
    @IBOutlet weak var CameraView: UIImageView!
    
    @IBOutlet weak var CenterSpotLabel: UILabel!
    @IBOutlet weak var SubmitBtn: UIButton!
    
    var discovery: FLIRDiscovery?
    var camera: FLIRCamera?
    var thermalStreamer: FLIRThermalStreamer?
    var stream: FLIRStream?
    var dataFlirDelagate: DataFlirDelegate?
    var currentTemp: Double = 0.0
    let renderQueue = DispatchQueue(label: "render")
    
    var orientations = UIInterfaceOrientationMask.portrait
     override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
     get { return self.orientations }
     set { self.orientations = newValue }
     }

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//            super.viewWillTransition(to: size, with: coordinator)
//            if UIDevice.current.orientation.isLandscape {
//                dataFlirDelagate?.logToIonic("landscape")
//            } else {
//                dataFlirDelagate?.logToIonic("portrait")
//            }
//        }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        SubmitBtn.layer.cornerRadius = 30;
        SubmitBtn.layer.borderColor = UIColor.white.cgColor
        SubmitBtn.layer.borderWidth  = 9.0
        SubmitBtn.isHidden = true
        discovery = FLIRDiscovery()
        discovery?.delegate = self
        dataFlirDelagate?.logToIonic("View loaded")
        discovery?.start([.lightning])
    }
    
    @IBAction func DismissButtonPressed(_ sender: UIButton) {
        camera?.disconnect()
        
        let image = CameraView.image!
        let scaledImg = scale(newWidth: 1800.0, img: image);
        let scaledAndTextImg = textToImage(drawText: String(currentTemp) + "°C", inImage: scaledImg, atPoint: CGPointMake((scaledImg.size.width.native / 2) - 50,
                                                                                                                          (scaledImg.size.height.native / 2) + 60), fontSize: 42.0)
        let scaledAndTextImgWithMarker = textToImage(drawText: "O", inImage: scaledAndTextImg, atPoint: CGPointMake((scaledImg.size.width.native / 2) - 25,
                                                                                                             (scaledImg.size.height.native / 2) - 25 ), fontSize: 78.0)
        let imageString = convertImageToBase64String(img: scaledAndTextImgWithMarker);
        let temp = currentTemp
        dataFlirDelagate?.hasDismissed(temp: temp, img: imageString)
        self.dismiss(animated: true)
    }
    
    @IBAction func CancelButtonPressed(_ sender: UIButton) {
        if(camera != nil){
            camera?.disconnect()
        }
        dataFlirDelagate?.hasCancelled()
        self.dismiss(animated: true)
    }
    
    func requireCamera() {
        guard camera == nil else {
            return
        }
        let camera = FLIRCamera()
        self.camera = camera
        camera.delegate = self
        SubmitBtn.isHidden = false
    }
    
    func scale(newWidth: Double,img: UIImage) -> UIImage
    {
        let scale = UIScreen.main.scale
        let scaledWidth = round(newWidth / scale);
        let targetSize = CGSize(width: scaledWidth, height: scaledWidth)

        let widthScaleRatio = targetSize.width / img.size.width
        let heightScaleRatio = targetSize.height / img.size.height
        
        let scaleFactor = min(widthScaleRatio, heightScaleRatio)
        
        let scaledImageSize = CGSize(
            width: img.size.width * scaleFactor,
            height: img.size.height * scaleFactor
        )
      
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            img.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.6)?.base64EncodedString() ?? ""
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, fontSize: Double) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: fontSize)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
}









extension DataFlirViewController: FLIRDiscoveryEventDelegate {

    public func cameraFound(_ cameraIdentity: FLIRIdentity) {
        dataFlirDelagate?.logToIonic("Camera Found")
        if(cameraIdentity.cameraType() != .flirOne)
        {
            return
        }
        requireCamera()
        guard !camera!.isConnected() else {
            return
        }
        DispatchQueue.global().async {
            do {
                try self.camera?.connect(cameraIdentity)
                let streams = self.camera?.getStreams()
                guard let stream = streams?.first else {
                    NSLog("No streams found on camera!")
                    return
                }
                self.stream = stream
                let thermalStreamer = FLIRThermalStreamer(stream: stream)
                self.thermalStreamer = thermalStreamer
                thermalStreamer.autoScale = true
                thermalStreamer.renderScale = true
                stream.delegate = self
                do {
                    try stream.start()
                } catch {
                    NSLog("stream.start error \(error)")
                }
            } catch {
                NSLog("Camera connect error \(error)")
            }
        }
        
        
        
        
    }
    
    //public func cameraDiscovered(_ discoveredCamera: FLIRDiscoveredCamera){
    //    dataFlirDelagate?.logToIonic("cameraDiscovered")
    //}

    public func discoveryError(_ error: String, netServiceError nsnetserviceserror: Int32, on iface: FLIRCommunicationInterface) {
        dataFlirDelagate?.logToIonic("discoveryError")
    }

    public func discoveryFinished(_ iface: FLIRCommunicationInterface) {
        dataFlirDelagate?.logToIonic("discoveryFinished")
    }

    public func cameraLost(_ cameraIdentity: FLIRIdentity) {
        dataFlirDelagate?.logToIonic("cameraLost")
    }
}
extension DataFlirViewController : FLIRDataReceivedDelegate {
    public func onDisconnected(_ camera: FLIRCamera, withError error: Error?) {
        dataFlirDelagate?.logToIonic("onDisconnected")

    }
}

extension DataFlirViewController : FLIRStreamDelegate {
    public func onError(_ error: Error) {
        dataFlirDelagate?.logToIonic("onError")
    }

    func onImageReceived() {
        renderQueue.async {
            do {
                try self.thermalStreamer?.update()
            } catch {
                NSLog("update error \(error)")
            }
            let image = self.thermalStreamer?.getImage()
            DispatchQueue.main.async {
                self.CameraView.image = image
                self.thermalStreamer?.withThermalImage { image in
                    
                    image.palette = image.paletteManager?.iron
                    
                    
                    if let measurements = image.measurements {
                        if measurements.getAllSpots().isEmpty {
                            do {
                                try measurements.addSpot(CGPoint(x: CGFloat(image.getWidth()) / 2,
                                                                 y: CGFloat(image.getHeight()) / 2))
                               
                            } catch {
                                NSLog("addSpot error \(error)")
                            }
                        }
                        if let spot = measurements.getAllSpots().first {
                            self.currentTemp = round((spot.getValue().value - 273.15)*10) / 10
                            self.CenterSpotLabel.text = String(self.currentTemp) + "°C"
                        }
                    }
                }
            }
        }
    }
}

protocol DataFlirDelegate{
    func logToIonic(_ message:String)
    func hasDismissed(temp: Double, img: String)
    func hasCancelled()
}

