//
//  imageEditViewController.swift
//  EulerityChallenge
//
//  Created by Rinchen on 9/16/21.
//

import UIKit
import AlamofireImage
import Alamofire
import CoreImage
//import MetalKit1

class imageEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    let imageProvide: ImageProvider

    var images: [String: Any]!
    @IBOutlet weak var imageLabel: UIImageView!
    var someImage : UIImage!
    var currentImage: UIImage!
    var context: CIContext!
    @IBOutlet weak var intensity: UISlider!
    var currentFilter: CIFilter!
    var imageUrl: Any?
    var uploadURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: images["url"] as! String)!
        self.imageUrl = URL(string: images["url"] as! String)!

        print("MAking REquest")
        print(url)
        print("URL END")
        
        createSpinnerView()
        
       
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // then remove the spinner view controller
            self.loadImage()
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }

    
    
    func loadImage(){

        print("Begin Loading context")
        context = CIContext()
        
        self.currentFilter = CIFilter(name: "CISepiaTone")
        self.someImage = self.imageLabel.image
        
        print("Begin Processing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.applyProcessing()
        }
        
    }
    
    @IBAction func intensityChange(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "choose filter", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "No Filter", style: .default, handler: resetImage))
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController{
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            
        }
        
        present(ac, animated: true)
    }
    
    @IBAction func addText(_ sender: Any) {
        
        let label = "thi is a overlay"
        
        self.currentImage = textToImage(drawText: label, inImage: self.imageLabel.image!, atPoint: CGPoint(x: self.imageLabel.image!.size.height/2, y: 50))
    }
    
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!

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

        print("settingimagelabel")
        self.imageLabel.image = newImage!
        return newImage!
    }
    
    func resetImage(action: UIAlertAction){
        self.imageLabel.image = self.someImage
        loadImage()
    }
    
    func setFilter(action: UIAlertAction){
        print(action.title!)
        guard currentImage != nil else {return}
        guard let actionTitle = action.title else {return}
        
        self.currentFilter = CIFilter(name: actionTitle)
        let beginImage = CIImage(image: currentImage)
        self.currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        
    }
    
    func getUploadUrl(){
//        var imageData = UIImageJPEGRepresentation(imageLabel.image, 90)
        var uploadUrl = ""
        let url = URL(string: "https://eulerity-hackathon.appspot.com/upload")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as! [String: Any]

                uploadUrl = dataDictionary["url"] as! String
                print("from getUploadUrl():", uploadUrl)
//                self.collectionView.reloadData()
                self.uploadURL = uploadUrl
                
             }
        }
            task.resume()
    }
    
    @IBAction func save(_ sender: Any) {
        getUploadUrl()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.uploadImage()
            
        }
        
      }
    func postRequest(){
        
        let config = URLSessionConfiguration.default

        let session = URLSession(configuration: config)
        print("calling get Upload : ")
        getUploadUrl()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            print("self.uploadurl: ", self.uploadURL)
            let up = self.uploadURL
            print("THE BIG ***** : ", up)
        let url = URL(string: up )!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        // your post request data
        let postDict : [String: Any] = ["appid": "rinchenlama0075",
                                        "original": self.imageLabel.image as Any,
                                        "file": self.imageLabel.image as Any]

        guard let postData = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
            return
        }

        urlRequest.httpBody = postData

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
            print(error.localizedDescription)
     } else if let data = data {
        let dataDictionary : NSArray! = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSArray

        print("Upload success")
        
     }        }

        task.resume()
        }
    }
    
    
    func applyProcessing(){
        
        let inputKeys = self.currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            self.currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            self.currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            self.currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey){
            self.currentFilter.setValue(CIVector(x: self.currentImage.size.width / 2, y: self.currentImage.size.height / 2 ), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = self.currentFilter.outputImage else {return}
        print("Begin Loading currentFilter")
        
            print("stuff")
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    let processedImage = UIImage(cgImage: cgimg)
            
                    self.imageLabel.image = processedImage
                    print("processed image was processd")
                    
                }
        
        print("apply process ended")
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func uploadImage(){
        // the image in UIImage type
        guard let image = self.currentImage else { return  }

        let filename = "avatar.png"

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        let fieldName = "reqtype"
        let fieldValue = "fileupload"

        let fieldName2 = "userhash"
        let fieldValue2 = "caa3dce4fcb36cfdf9258ad9c"

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: self.uploadURL)!)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the reqtype field and its value to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)

        // Add the userhash field and its value to the raw http reqyest data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue2)".data(using: .utf8)!)

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
            }
        }).resume()
    }

}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
