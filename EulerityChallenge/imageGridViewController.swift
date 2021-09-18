//
//  imageGridViewController.swift
//  EulerityChallenge
//
//  Created by Rinchen on 9/16/21.
//

import UIKit
import AlamofireImage
import Alamofire

class imageGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionViewCell", for: indexPath) as! imageCollectionViewCell
        
        let image=images[indexPath.item]
        let imageUrl = URL(string: image["url"] as! String)!
        cell.imageLabel.af.setImage(withURL: imageUrl)
//        cell.imageNum.text = "num \(indexPath.row)"
        
//        cell.imageLabel

        return cell
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var images = [[String:Any?]]()
//    @IBOutlet weak var imageGridView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let url = URL(string: "https://eulerity-hackathon.appspot.com/image")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                let dataDictionary : NSArray! = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSArray

                self.images = dataDictionary as! [[String : Any?]]
                self.collectionView.reloadData()
                
             }
        }
        task.resume()
        

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let image = images[indexPath.row]
        
        let editViewController = segue.destination as! imageEditViewController
        
        editViewController.images = image
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
        let url = image["url"] as! String
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            AF.request(url as URLConvertible ,method: .get).response{ response in
               switch response.result {
                case .success(let responseData):
                    editViewController.imageLabel.image = UIImage(data: responseData!, scale:1)
                    editViewController.currentImage = editViewController.imageLabel.image
                    print("IT WAS A SUCC")

                case .failure(let error):
                    print("error--->",error)
                }
                
                print("SHEEE GOT ZUCC")
            }
        }
            
        
        
        print("PREPARATION COMPLETE ****************")
    }
    

}
