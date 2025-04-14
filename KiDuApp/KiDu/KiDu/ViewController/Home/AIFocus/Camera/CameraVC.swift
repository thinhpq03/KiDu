//
//  CameraVC.swift
//  KiDU
//
//  Created by Phạm Quý Thịnh on 27/3/25.
//

import UIKit
import AVFoundation
import Vision
import Photos
import CoreML

enum LabelDetectionError: Error {
    case invalidImage
    case modelLoadingFailed
    case noResults
}

class CameraVC: BaseVC {

    @IBOutlet weak var cameraView: CameraPreviewView!

    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var activeCaptureDeviceInput: AVCaptureDeviceInput!
    private let sessionQueue = DispatchQueue(label: "Capture Session")
    private var isUsingFrontCamera = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    func setupView() {
        cameraView.layer.cornerRadius = 50
        cameraView.clipsToBounds = true
        cameraView.layer.borderColor = UIColor(hex: "F9A545").cgColor
        cameraView.layer.borderWidth = 1.5
    }

    private func initCaptureSession() {
        cameraView.session = captureSession
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            case .authorized:
                startPhotoSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.startPhotoSession()
                        }
                    } else {
                        self.view.showMsg("Photo capture permission denied.")
                    }
                }
            case .denied, .restricted:
                self.view.showMsg("Photo capture permission denied or restricted.")
            @unknown default:
                self.view.showMsg("Unknown authorization status.")
        }
    }

    private func startPhotoSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        let position: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            self.view.showMsg("No photo device found")
            return
        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            self.view.showMsg("Failed to create photo device input")
            return
        }

        if let currentInput = activeCaptureDeviceInput {
            captureSession.removeInput(currentInput)
        }

        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
            activeCaptureDeviceInput = videoDeviceInput
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        DispatchQueue.main.async {
            self.cameraView.videoPreviewLayer.connection?.videoOrientation = .portrait
            self.cameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
        }

        captureSession.commitConfiguration()
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }

    private func presentGalleryPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

    func performObjectDetection(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: YOLOv3Int8LUT().model) else {
            fatalError("Failed to load model")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                DispatchQueue.main.async {
                    self?.showAlert(message: "Failed to process image. Please try with another image.")
                }
                return
            }

            var foundLabel = false

            for observation in results {
                if let firstLabel = observation.labels.first {
                    foundLabel = true
                    DispatchQueue.main.async {
                        let aiFocus = AIFocusVC()
                        aiFocus.detectedText = firstLabel.identifier
                        aiFocus.originalImage = image
                        self?.navigationController?.pushViewController(aiFocus, animated: true)
                    }
                    break
                }
            }

            if !foundLabel {
                DispatchQueue.main.async {
                    self?.showAlert(message: "Failed to process image. Please try with another image.")                }
            }
        }

        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create CIImage from UIImage")
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform request: \(error)")
            }
        }
    }

    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @IBAction func roateCamera(_ sender: Any) {
        isUsingFrontCamera.toggle()
        startPhotoSession()
    }

    @IBAction func getGallery(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized, .limited:
                presentGalleryPicker()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    DispatchQueue.main.async {
                        if #available(iOS 14, *) {
                            if newStatus == .authorized || newStatus == .limited {
                                self.presentGalleryPicker()
                            } else {
                                self.view.showMsg("Photo Library access denied.")
                            }
                        } else {
                            return
                        }
                    }
                }
            case .denied, .restricted:
                self.view.showMsg("Photo Library access denied.")
            @unknown default:
                self.view.showMsg("Unknown Photo Library authorization status.")
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            performObjectDetection(image: selectedImage)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            self.view.showMsg("Failed to capture photo.")
            return
        }
        if let image = UIImage(data: imageData) {
            performObjectDetection(image: image)
        }
    }
}

