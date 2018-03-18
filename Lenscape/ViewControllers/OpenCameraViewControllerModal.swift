//
//  OpenCameraViewControllerModal.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 17/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import AVFoundation

class OpenCameraViewControllerModal: UIViewController {

    @IBOutlet weak var cameraButton: UIView!
    @IBOutlet weak var previewView: UIView!
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShotButtonGesture()
        initCamera()
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func addShotButtonGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(snapPhoto))
        cameraButton.addGestureRecognizer(tap)
        cameraButton.isUserInteractionEnabled = true
    }
    
    private func initCamera() {
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
            }
            // ...
            // The remainder of the session setup will go here...
        }
    }
    
    @objc private func snapPhoto() {
        if let videoConnection = stillImageOutput!.connection(with: AVMediaType.video) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let dataProvider = CGDataProvider(data: imageData! as CFData )
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    self.showPhotoPostViewController(image: image)
                }
            })
        }
    }
    
    private func showPhotoPostViewController(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: Identifier.PhotoPostViewController.rawValue) as? PhotoPostViewController else {
            fatalError("identifier: \(Identifier.PhotoPostViewController.rawValue) is not type of PhotoPostViewController")
        }
        vc.image = image
        print("BBBBBB")
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        videoPreviewLayer!.frame = previewView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        print("segue")
    }

    @IBAction func unwindToCameraAndDisiss(sender: UIStoryboardSegue) {
        dismiss(animated: false, completion: nil)
    }

}
