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

    // MARK: - UI Components
    @IBOutlet weak var cameraRollButton: UIView!
    @IBOutlet weak var dismissButton: UIView!
    @IBOutlet weak var cameraButton: UIView!
    @IBOutlet weak var previewView: UIView!
    
    // MARK: - Attributes
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var imagePickerController = UIImagePickerController()
    
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        addShotButtonGesture()
        addDismissButtonGesture()
        addOpenCameraRollGesture()
        initCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        videoPreviewLayer!.frame = previewView.bounds
    }
    
    
    // MARK: - ImagePickerController functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        dismiss(animated: true)
        showPhotoPreviewController(image: selectedImage)
    }
    
    // MARK: - UI Initialization
    
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
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
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
                    self.showPhotoPreviewController(image: image)
                }
            })
        }
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Misc
    
    private func showPhotoPreviewController(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: Identifier.PhotoPreviewViewController.rawValue) as? PhotoPreviewViewController else {
            fatalError("identifier: \(Identifier.PhotoPreviewViewController.rawValue) is not type of PhotoPreviewViewController")
        }
        vc.image = image
        vc.hero.isEnabled = true
        vc.hero.modalAnimationType = .pageIn(direction: .left)
        present(vc, animated: true)
    }

    // MARK: - Unwind
    @IBAction func unwindToCameraAndDisiss(sender: UIStoryboardSegue) {
        dismiss(animated: false)
    }

}
