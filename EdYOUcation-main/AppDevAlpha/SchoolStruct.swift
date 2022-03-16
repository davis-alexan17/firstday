//
//  SchoolStruct.swift
//  AppDevAlpha
//
//  Created by James Magee on 12/24/19.
//  Copyright © 2019 Innovation Center. All rights reserved.
//

import Foundation
import UIKit

///
//  MARK: SCHOOL STRUCTS
///
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
public extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
struct School_Data: Codable {
    let id: Int
    let name: String
    var imgKey: String?
    let categories: [Category]
    
    func img_url() -> String {
        return config.api.base_url+config.api.get_imgs+"schools/"+String(id)
    }
}

struct Category: Codable {
    let id: Int
    let name_eng: String?
    let name_esp: String?
    let text_eng: String?
    let text_esp: String?
    let imgKey: String?
    let profiles: [Profile]
    
    /**
     Returns the name of the category. If both English and Spanish are available, returns the preferred language (set in: Schools_Controller.espanol).
     */
    func name() -> String {
        
        /// ensure names in both languages exist - if not, return the name that does exist
        guard let nameInSpanish = name_esp else {
            return name_eng!
        }
        guard let nameInEnglish = name_eng else {
            return name_esp!
        }
        /// if both exist, return the spanish name if Schools_Controller.espanol == true, else return the english name.
        if (Schools_Controller.espanol) {
            return nameInSpanish
        } else {
            return nameInEnglish
        }
    }
    
    func text() -> String {
        if (Schools_Controller.espanol) {
            print("LASLFLASLFLASGKSDGHLKJHB")
            return text_esp!
            
        } else {
            print("LAsdgf")
            return text_eng!
        }
    }
    
    func img_url() -> String {
        return config.api.base_url+config.api.get_imgs+"categories/"+String(id)
    }
}

struct Profile: Codable {
    let id: Int
    let name_eng: String?
    let name_esp: String?
    let text_eng: String?
    let text_esp: String?
    let imgKey: String?
    
    func name() -> String {
        if (Schools_Controller.espanol) {
            return name_esp!
        } else {
            return name_eng!
        }
    }
    
    func text() -> String {
        if (Schools_Controller.espanol) {
            
            return text_esp!
        } else {
            return text_eng!
        }
    }
    
    func img_url() -> String {
        return config.api.base_url+config.api.get_imgs+"profiles/"+String(id)
    }
}
/*
struct apiKeys {
    static let api_key = "WAHDO)@$(@W(DJ"
    //??
}*/

struct config {
    static let local_data_url = "schools.json"
    
    struct api {
        static let local_test = ""
        static let base_url = "http://127.0.0.1:5000"
        
        //"http://127.0.0.1:5000"
        static let get_imgs = "/getimgs/"
    }
}


///
// MARK: SCHOOLS_CONTROLLER
///

class Schools_Controller {
    // set to "es" or "en" for testing
    static var espanol = (NSLocale.current.languageCode == "en")
     
    static var schools: [String:School_Data] = [:]
    
    
    /**
        - Loads local data (run if the request to the server is unsuccesful
     */
    static func loadSchools() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let subUrl = documentDirectory.appendingPathComponent(config.local_data_url)
            
            let decoder = JSONDecoder()
            let jsonData = try Data(contentsOf: subUrl)
            let schoolList = try decoder.decode([School_Data].self, from: jsonData)
            // append data to the class
            for school in schoolList {
                schools[school.name] = school
            }
        } catch {
            print(error)
        }
    }
    
    static func saveSchools() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let subUrl = documentDirectory.appendingPathComponent(config.local_data_url)
            
            let encoder = JSONEncoder()
            let schoolData = Array(schools.values)
            let data = try encoder.encode(schoolData)
            try data.write(to: subUrl)
        } catch {
            print(error)
        }
    }
    
    /**
            - Description:
        Call to find the available schools. This will automatically try to download new school data. If it fails, it will return whatever data is stored locally. If it succeeds, it will replace the local data with the new data.
    */
    
    static func findSchools(school: String?, completion: @escaping ()->Void) {
        getData(from: URL(string: config.api.base_url+"/get_json/schools")!)  // "http://appdev-env-1.eba-c3upifba.us-west-2.elasticbeanstalk.com/get_json/schools"
        {(data, res, error) in
            
            guard (data != nil) else {
                print("DATA == NIL")
                loadSchools()
                completion()
                return
            }
            
            guard (error == nil) else {
                print("ERROR != NIL")
                loadSchools()
                completion()
                return
            }
            
            do {
                // Decode data from GET request, and save it to the class for use
//                print(type(of: data!))
                let stringValue = String(decoding: data!, as: UTF8.self)
                print(stringValue)
                print("AT THIS POINT: ", "\n\n\n")

                let decoder = JSONDecoder()
                let schoolList = try decoder.decode([School_Data].self, from: data!)
                for school in schoolList {
                    schools[school.name] = school
                    saveImgData(school_: school)
                }
                // Assign path to where the data will be stored
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let subUrl = documentDirectory.appendingPathComponent("schools.json")
                // Store the data
                try data!.write(to: subUrl)
            } catch {
                print(error)
            }
            completion()
        }
    }
    
    
    /**
        - Saves image data locally (so it can be accessed via getImage)
     */
    static func saveImgData(school_: School_Data) {
        do {
            print(Locale.current.languageCode)
            if school_.id != 0 && school_.imgKey != nil && school_.imgKey != "None" {
                let data = try? Data(contentsOf: URL(string: school_.img_url())!)
                print("\n\n\nDEBUG:\n\n\n", school_.img_url())
                print(data)
                if(data != nil){
                _ = saveImage(image: UIImage(data: data!)!, fileName: school_.imgKey!)
                }
                
            }
            for category in school_.categories {
                if category.imgKey != nil && category.imgKey != "None" {
                    let c_data = try? Data(contentsOf: URL(string: category.img_url())!)
                    print(category.img_url())
                    print(c_data)
                    if(c_data != nil){
                     _ = saveImage(image: UIImage(data: c_data!)!, fileName: category.imgKey!)
                    }
                } // http://localhost:5000/getimgs/categories/2
                for profile in category.profiles {
                    if profile.imgKey != nil && profile.imgKey != "None" {
                        let p_data = try? Data(contentsOf: URL(string: profile.img_url())!)
                        print(p_data)
                        if(p_data != nil){
                         _ = saveImage(image: UIImage(data: p_data!)!, fileName: profile.imgKey!)
                        }
                    }
                }
            }
        }
    }
    
    

    // Function for HTTP req (making code easier to read)
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // Save an image
    static func saveImage(image: UIImage, fileName: String) -> Bool {
        
        guard let data = image.pngData() ?? image.jpegData(compressionQuality: 1)  else {
            return false
        }
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(fileName))
            return true
        } catch {
            print("YEAH NOPE")
            print(error.localizedDescription)
            return false
        }
    }
    
    static func getImage(imgKey: String) -> UIImage? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        do {
            let imageData = try Data(contentsOf: directory.appendingPathComponent(imgKey))
            return UIImage(data: imageData)
        } catch {
            print(error)
        }
        return nil
    }
    
}



//class School_Class {
//
//    let name: String
//    let path: String
//    static let fileManager = FileManager.default
//
//    init(name: String, nonImgDataFilePath: String, imgDataFilePath: String) {
//        self.name = name
//        self.path = name
//    }
//
//    func getData() -> School_Data? {
//        if let schoolJson = defaults.string(forKey: self.path) {
//            do {
//                return try JSONDecoder().decode(School_Data.self, from: Data(base64Encoded: schoolJson)!)
//            } catch {
//                print("ERROR GETTING DATA FOR SCHOOL: \(self.name)\n\n\n")
//                print(error)
//            }
//        }
//        return nil
//    }

// Grab images ... this could use some re-thinking, if possible
//    static func saveImgData(school_: School_Data) {
//        if school_.imgKey != nil && school_.imgKey != "None" {
//            getData(from: URL(string: (apiKeys.url+"/getimgs/schools/\(school_.id)"))!) { (data, res, err) in
//                guard data != nil, res == nil else {print("PROBLEM WITH SCHOOL IMGKEY");return}
//                _ = saveImage(image: UIImage(data: data!)!, fileName: school_.imgKey!)
//            }
//        }
//        for category in school_.categories {
//            if category.imgKey != nil && category.imgKey != "None" {
//                getData(from: URL(string: (apiKeys.url+"/getimgs/categories/\(category.id)"))!) {
//                    (data, res, err) in
//                    guard data != nil, res == nil else {print("PROBLEM WITH CATEGORY IMG KEY: \(category.id)");return }
//                    _ = saveImage(image: UIImage(data: data!)!, fileName: category.imgKey!)
//                }
//            } // http://localhost:5000/getimgs/categories/2
//            for profile in category.profiles {
//                if profile.imgKey != nil && profile.imgKey != "None" {
//                    getData(from: URL(string: (apiKeys.url+"/getimgs/profiles/\(profile.id)"))!) {
//                        (data, res, err) in
//                        guard data != nil, res == nil else {print("PROBLEM WITH PROFILE IMGKEY");return }
//                        _ = saveImage(image: UIImage(data: data!)!, fileName: profile.imgKey!)
//                    }
//                }
//            }
//        }
//    }
