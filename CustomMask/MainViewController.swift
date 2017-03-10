//
//  MainViewController.swift
//  CustomMask
//
//  Created by admin_user on 3/10/17.
//  Copyright © 2017 GMService. All rights reserved.
//

import UIKit
import CameraManager

class MainViewController: UIViewController {
    
    @IBOutlet weak var ivDolphin: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    var viewCamera: UIView!
    var ivCapturedView: UIImageView!
    
    let cameraManager = CameraManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup camera view.
        viewCamera = UIView()
        let width = viewContainer.frame.size.height / 7
        let height = viewContainer.frame.size.height / 4
        let x = viewContainer.center.x - width - 10
        let y = viewContainer.center.y - height - 30
        viewCamera.frame = CGRect(x: x, y: y, width: width, height: height)
        viewCamera.backgroundColor = UIColor.red
        viewContainer.insertSubview(viewCamera, belowSubview: ivDolphin)
        
        // Setup image view which will keep the image captured.
        ivCapturedView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
        ivCapturedView.contentMode = .scaleAspectFill
        viewContainer.insertSubview(ivCapturedView, belowSubview: viewCamera)
        
        // Setup camera manager settings.
        cameraManager.cameraDevice = .front
        cameraManager.showAccessPermissionPopupAutomatically = true
        cameraManager.cameraOutputMode = .stillImage
        cameraManager.cameraOutputQuality = .high
        cameraManager.writeFilesToPhoneLibrary = false
        let cameraState = cameraManager.addPreviewLayerToView(viewCamera)
        print("Camera State: \(cameraState)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCaptureButton(_ sender: UIButton) {
        cameraManager.capturePictureWithCompletion { (image, error) in
            self.cameraManager.stopCaptureSession()
            let flippedImage = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
            self.ivCapturedView.image = flippedImage
            self.saveImageToCameraRoll()
        }
    }
    
    func saveImageToCameraRoll() {
        self.viewCamera.isHidden = true
        
        // Create an image with custom mask.
        let renderer = UIGraphicsImageRenderer(size: viewContainer.bounds.size)
        let image = renderer.image(actions: { (context) in
            viewContainer.drawHierarchy(in: viewContainer.bounds, afterScreenUpdates: true)
        })
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let alertController = UIAlertController(title: "Image Saved!", message: "Find it in Camera Roll album", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in
            // Resume capture session.
            self.viewCamera.isHidden = false
            self.cameraManager.resumeCaptureSession()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
