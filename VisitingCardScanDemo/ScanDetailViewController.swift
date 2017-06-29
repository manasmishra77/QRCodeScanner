//
//  ScanDetailViewController.swift
//  VisitingCardScanDemo
//
//  Created by Manas Mishra on 29/06/17.
//  Copyright © 2017 Manas Mishra. All rights reserved.
//

import UIKit
import AVFoundation

class ScanDetailViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scanNew: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var at: UILabel!
  
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var pickedImage: UIImage?
    var contactDict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scanFromPhotos.layer.cornerRadius = 12
        scanNew.layer.cornerRadius = 12
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var saveDetails: UIBarButtonItem!
    @IBAction func saveDetailsTapped(_ sender: Any) {
        if name.text != ""{
            if let dictArray = UserDefaults.standard.array(forKey: "ContactArray"){
                var newDictArray = dictArray
                newDictArray.append(contactDict)
                UserDefaults.standard.set(newDictArray, forKey: "ContactArray")
            }
            else{
               let newDictArray = [contactDict]
                UserDefaults.standard.set(newDictArray, forKey: "ContactArray")
            }
            navigationController?.popViewController(animated: true)
        }
        else{
            let alertVC = UIAlertController(title: "Empty Field", message: "Please select once again", preferredStyle: .alert)
            present(alertVC, animated: true, completion: nil)
        }
    }

    @IBAction func scanNew(_ sender: Any) {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                converting(text: metadataObj.stringValue)
                changingLabels()
            }
        }
    }
    @IBOutlet weak var scanFromPhotos: UIButton!
    @IBAction func onScanFromPhotos(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorSmile: CIDetectorAccuracyHigh])
            let ciImage = CIImage(image: newImage)
            var qrCodeLink = ""
            let features = detector?.features(in: ciImage!)
            for feature in features as! [CIQRCodeFeature]{
                 qrCodeLink += feature.messageString!
            }
            
            
            print(qrCodeLink)
            converting(text: qrCodeLink)
            changingLabels()
            
        }
        dismiss(animated: true, completion: nil)
    }
    func converting(text: String){
        let subtexts = text.components(separatedBy: CharacterSet(charactersIn: "\n"))
        for subtext in subtexts{
            var abc = subtext.components(separatedBy: CharacterSet(charactersIn: ":"))
            var getData = [String]()
            if abc[0] == "N"{
                getData = abc[1].components(separatedBy: CharacterSet(charactersIn: ";"))
                if getData.count > 0{
                    contactDict["name"] = getData[0]
                }
            }
            else if abc[0] == "TITLE"{
                getData = abc[1].components(separatedBy: CharacterSet(charactersIn: ";"))
                if getData.count > 0{
                    contactDict["title"] = getData[0]
                }
            }
            else if abc[0] == "ORG"{
                getData = abc[1].components(separatedBy: CharacterSet(charactersIn: ";"))
                if getData.count > 0{
                    contactDict["company"] = getData[0]
                }
            }
            else if abc[0] == "EMAIL;TYPE=INTERNET"{
                getData = abc[1].components(separatedBy: CharacterSet(charactersIn: ";"))
                if getData.count > 0{
                    contactDict["at"] = getData[0]
                }
            }
            else if abc[0] == "TEL;TYPE=voice,cell,pref"{
                contactDict["contact"] = abc[1]
            }
    }
        
 }
    func changingLabels() {
        name.text = contactDict["name"]
        designation.text = contactDict["title"]
        company.text = contactDict["company"]
        contactNumber.text = contactDict["contact"]
        at.text = contactDict["at"]
    }
    
}

















