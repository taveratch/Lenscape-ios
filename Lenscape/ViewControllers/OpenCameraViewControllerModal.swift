//
//  OpenCameraViewControllerModal.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 17/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import AVFoundation

class OpenCameraViewControllerModal: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraRollButton: UIImageView!
    @IBOutlet weak var dismissButton: UIImageView!
    @IBOutlet weak var cameraButton: UIView!
    @IBOutlet weak var previewView: UIView!
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private lazy var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        addShotButtonGesture()
        addDismissButtonGesture()
        addOpenCameraRollGesture()
        initCamera()
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - ImagePickerController functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        dismiss(animated: true)
        showPhotoPostViewController(image: selectedImage)
    }
    
    // MARK: - UI initialize functions
    
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
    
    // MARK: - Gestures
    
    private func addShotButtonGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(snapPhoto))
        cameraButton.addGestureRecognizer(tap)
        cameraButton.isUserInteractionEnabled = true
    }
    
    
    private func addDismissButtonGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        dismissButton.addGestureRecognizer(tap)
        dismissButton.isUserInteractionEnabled = true
    }
    
    private func addOpenCameraRollGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openCameraRoll))
        cameraRollButton.addGestureRecognizer(tap)
        cameraRollButton.isUserInteractionEnabled = true
    }
    
    @objc private func openCameraRoll() {
        present(imagePickerController, animated: true, completion: nil)
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
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - misc
    
    private func showPhotoPostViewController(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: Identifier.PhotoPostViewController.rawValue) as? PhotoPostViewController else {
            fatalError("identifier: \(Identifier.PhotoPostViewController.rawValue) is not type of PhotoPostViewController")
        }
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        videoPreviewLayer!.frame = previewView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - unwind
    @IBAction func unwindToCameraAndDisiss(sender: UIStoryboardSegue) {
        dismiss(animated: false, completion: nil)
    }

}
