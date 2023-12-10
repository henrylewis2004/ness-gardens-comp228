//
//  detailsViewController.swift
//  ness gardens comp228
//
//  Created by Lewis, Henry on 10/12/2023.
//

import UIKit

struct ImageInfoResponse: Codable{
    var images: [ImageInfo]
}

struct ImageInfo: Codable{
    var recnum: String?
    var imgid: String?
    var img_file_name: String?
    var imgtitle: String?
    var photodt: String?
    var photonme: String?
    var copy: String?
    var last_modified: String?
}

class detailsViewController: UIViewController {
    var plantDetails = Plant()
    var images = [UIImage]()
    var imageInfoArray = [ImageInfo]()
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task{
            await downloadImages()//recnum: plantDetails.recnum!)
            
        }
        
    }
    
    func downloadImages()async{
        imageInfoArray = []
        images = []
        let jsonDecoder = JSONDecoder()
        let recnum = "52"
        let ImageInfoURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=images&recnum=\(recnum)")!
        
        do{
            var (data,_) = try await URLSession.shared.data(from: ImageInfoURL)
            do{
                let result = try jsonDecoder.decode(ImageInfoResponse.self, from: data)
            
                imageInfoArray = result.images
                
            }
            catch DecodingError.keyNotFound(let key, _){print("image info key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("image info value: \(value) not found")}
           
            
        }
        catch{print("invalid data");return}
        for element in 1...imageInfoArray.count{
            let ImageURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/\(recnum)-ID\(element).jpg")!
            do{
                
                
                var (data,_) = try await URLSession.shared.data(from: ImageURL)

                    images.append(UIImage(data:data)!)
 
            }
            
            catch{print("invalid data");return}
    
        }
       
        
        
    }
}
