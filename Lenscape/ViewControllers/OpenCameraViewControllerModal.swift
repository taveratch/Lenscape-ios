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

    // MARK: - UI Components
    @IBOutlet private weak var cameraRollButton: UIView!
    @IBOutlet private weak var dismissButton: UIView!
    @IBOutlet private weak var cameraButton: UIView!
    @IBOutlet private weak var previewView: UIView!
    
    // MARK: - Attributes
    private var sessionQueue = DispatchQueue(label: "session queue")
    private var session: AVCaptureSession!
    private var imageOutput: AVCapturePhotoOutput!
    private var device: AVCaptureDevice!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var imagePickerController = UIImagePickerController()
    private var lastOrientation = UIDeviceOrientation.portrait
    
    // MARK: - Computed Properties
    
    private var photoSettings: AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = true
        return settings
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        addTapGesture(for: cameraButton, with: #selector(snapPhoto))
        addTapGesture(for: cameraRollButton, with: #selector(openCameraRoll))
        addTapGesture(for: dismissButton, with: #selector(close))
        sessionQueue.async { self.initCamera() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
            selector: #selector(rotated),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )
        sessionQueue.async {
            do {
                try self.device.lockForConfiguration()
                self.device.focusMode = .continuousAutoFocus
                self.device.exposureMode = .continuousAutoExposure
                self.device.unlockForConfiguration()
            } catch { print(error) }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
        setCurrentOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { self.session.stopRunning() }
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }

    /*
     Set current orientation to the same as it disappeared
    */
    private func setCurrentOrientation() {
        UIDevice.current.setValue(Int(lastOrientation.rawValue), forKey: "orientation")
    }
    
    // MARK: - UI Initialization
    
    private func initCamera() {
        session = AVCaptureSession()
        session.sessionPreset = .photo
        imageOutput = AVCapturePhotoOutput()
        imageOutput.isHighResolutionCaptureEnabled = true
        device = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            if session.canAddInput(input) {
                session.addInput(input)
                if session.canAddOutput(imageOutput) {
                    session.addOutput(imageOutput)
                    DispatchQueue.main.async {
                        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        self.videoPreviewLayer.videoGravity = .resizeAspectFill
                        self.videoPreviewLayer.connection?.videoOrientation = .portrait
                        self.videoPreviewLayer.frame = self.view.layer.bounds
                        self.previewView.layer.addSublayer(self.videoPreviewLayer)
                    }
                }
            }
            session.commitConfiguration()
        }
        catch {
            print(error)
        }
        
    }
    
    // MARK: - Camera Touch Focus
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = videoPreviewLayer.captureDevicePointConverted(
            fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view)
        )
        focus(at: devicePoint)
    }
    
    // MARK: - Unwind
    @IBAction func unwindToCameraAndDismiss(sender: UIStoryboardSegue) {
        dismiss(animated: false)
    }
    
    // MARK: - Objc functions (for action selector)
    @objc
    private func snapPhoto() {
        imageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc
    private func openCameraRoll() {
        present(imagePickerController, animated: true)
    }
    
    @objc
    private func close() {
        dismiss(animated: true)
    }
    
    @objc
    private func rotated() {
        rotateCameraRollImageView()
        lastOrientation = UIDevice.current.orientation
    }

}

// MARK: - UIImagePickerControllerDelegate
extension OpenCameraViewControllerModal: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        dismiss(animated: true)
        showPhotoPreviewController(image: selectedImage)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension OpenCameraViewControllerModal: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
        let image = processImage(data: photo.fileDataRepresentation())
        showPhotoPreviewController(image: image)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        previewView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.previewView.alpha = 1
        }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

}

// MARK: - Utilities Functions
extension OpenCameraViewControllerModal {
    
    private func processImage(data: Data?) -> UIImage {
        let dataProvider = CGDataProvider(data: data! as CFData)
        let cgImageRef = CGImage(
            jpegDataProviderSource: dataProvider!,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        
        var imageOrientation = UIImageOrientation.right
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            imageOrientation = .up
        case .landscapeRight:
            imageOrientation = .down
        default:
            break
        }
        
        return UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: imageOrientation)
    }
    
    private func showPhotoPreviewController(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: Identifier.PhotoPreviewViewController.rawValue) as? PhotoPreviewViewController else {
            fatalError("identifier: \(Identifier.PhotoPreviewViewController.rawValue) is not type of PhotoPreviewViewController")
        }
        vc.image = image
        vc.hero.modalAnimationType = .fade
        present(vc, animated: true)
    }
    
    private func rotateCameraRollImageView() {
        var angle: Double
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            angle = Double.pi / 2
        case .landscapeRight:
            angle = 3/2 * Double.pi
        default:
            angle = 2 * Double.pi
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.cameraRollButton.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        })
    }
    
    private func focus(at devicePoint: CGPoint) {
        sessionQueue.async {
            do {
                try self.device.lockForConfiguration()
                
                if self.device.isFocusPointOfInterestSupported &&
                    self.device.isFocusModeSupported(.autoFocus) {
                    self.device.focusPointOfInterest = devicePoint
                    self.device.focusMode = .autoFocus
                }
                
                if self.device.isExposurePointOfInterestSupported && self.device.isExposureModeSupported(.autoExpose) {
                    self.device.exposurePointOfInterest = devicePoint
                    self.device.exposureMode = .autoExpose
                }
                
                self.device.isSubjectAreaChangeMonitoringEnabled = true
                self.device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
}

// MARK: - References
/*
Migrate from AVCaptureStillImageOutput -> AVCapturePhotoOutput
 https://stackoverflow.com/questions/37869963/how-to-use-avcapturephotooutput?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
Retain current device orientation on view change
 https://stackoverflow.com/a/40263064/6344975
 https://www.pinterest.de/pin/223983781440138942/?autologin=true
Create custom camera view
 https://github.com/codepath/ios_guides/wiki/Creating-a-Custom-Camera-View
*/

