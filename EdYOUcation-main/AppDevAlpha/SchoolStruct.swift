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
            return text_esp!
        } else {
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
        static let base_url = "http://appdevwebform-env-1.eba-qg6juqmz.us-east-1.elasticbeanstalk.com"
        
        //"http://127.0.0.1:5000"
        static let get_imgs = "/getimgs/"
    }
}


///
// MARK: SCHOOLS_CONTROLLER
///

class Schools_Controller {
    // set to "es" or "en" for testing
    static var espanol = (NSLocale.current.languageCode == "es")
     
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
                _ = saveImage(image: UIImage(data: data!)!, fileName: school_.imgKey!)
            }
            for category in school_.categories {
                if category.imgKey != nil && category.imgKey != "None" {
                    let c_data = try? Data(contentsOf: URL(string: category.img_url())!)
                    print(category.img_url())
                    print(c_data)
                    _ = saveImage(image: UIImage(data: c_data!)!, fileName: category.imgKey!)
                } // http://localhost:5000/getimgs/categories/2
                for profile in category.profiles {
                    if profile.imgKey != nil && profile.imgKey != "None" {
                        let p_data = try? Data(contentsOf: URL(string: profile.img_url())!)
                        print(p_data)
                        _ = saveImage(image: UIImage(data: p_data!)!, fileName: profile.imgKey!)
                    }
                }
            }
        }
    }
    
    
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
//
//    func getData(test: Int) -> School_Data {
//        return School_Data(name: "Longs Peak",
//                           image: ImageWrapper(imageKey: "no_key"),
//                           categories: [Category(name: "Teachers",
//                                                 image: ImageWrapper(
//                                                    imageKey: "no_key"),
//                                                 list: nil,
//                                                 item: Item(
//                                                    name: "Mr. Reitzig",
//                                                    image: nil)),
//                                        Category(name: "Sports",
//                                                 image: nil,
//                                                 list: [Category(
//                                                    name: "Soccer",
//                                                    image: nil,
//                                                    list: nil,
//                                                    item: Item(
//                                                        name: "Soccer",
//                                                        image: nil))],
////                                                 item: nil)] )
////    }
//
//}


///[{"name": "Longs Peak Middle School", "categories": [{"name_eng": "Staff", "name_esp": "El personal", "text_eng": "Meet the teachers and administration that make Longs Peak such an amazing place to be!", "text_esp": "¡Conozca a los maestros y la administración que hacen de Longs Peak un lugar tan increíble para estar!", "profiles": [{"name_eng": "Kristy Heien (6th Grade)", "name_esp": "Kristy Heien (6 grado)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 1}, {"name_eng": "Wendy Schuller (6th Grade)", "name_esp": "Wendy Schuller (6 grado)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 2}, {"name_eng": "Caitlin O'Donnell (6th Grade)", "name_esp": "Caitlin O'Donnell (6 grado)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 3}, {"name_eng": "Andy Freeman (6th Grade)", "name_esp": "Andy Freeman (6 grado)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 4}, {"name_eng": "Tami Simon (6th Grade)", "name_esp": "Tami Simon (6 grado)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 5}, {"name_eng": "Pete Wysong (Art)", "name_esp": "Pete Wysong (Arte)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 6}, {"name_eng": "Monica Moreno-Martinez (STEM)", "name_esp": "Monica Moreno-Martinez (STEM)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 7}, {"name_eng": "Beckie Large-Swope (Librarian)", "name_esp": "Beckie Large-Swope (bibliotecaria)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 8}, {"name_eng": "Adrian Jiron (PE)", "name_esp": "Adrian Jiron (PE)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 9}, {"name_eng": "Courtney Adams (Technology)", "name_esp": "Courtney Adams (tecnología)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 10}, {"name_eng": "Katie Malone (Counseling)", "name_esp": "Katie Malone (asesoramiento)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 11}, {"name_eng": "Karin Blough (Assistant Principal)", "name_esp": "Karin Blough (director asistente)", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 12}], "imgKey": "image5.png", "id": 1}, {"name_eng": "Clubs", "name_esp": "Clubs", "text_eng": "Here are the award-winning clubs that you can join at Longs Peak!", "text_esp": "¡Aquí están los clubes galardonados a los que puede unirse en Longs Peak!", "profiles": [{"name_eng": "Art Club", "name_esp": "Club de arte", "text_eng": "Hear more information about Art Club from Mr. Wysong!", "name_esp": "¡Escuche más información sobre Art Club del Sr. Wysong!",  "imgKey": "None", "id": 13}, {"name_eng": "VEX Robotics", "name_esp": "Robótica VEX", "text_eng": "Hear more information about VEX Robotics from Ms. Moreno-Martinez!", "name_esp": "¡Escuche más información sobre VEX Robotics de la Sra. Moreno-Martinez!",  "imgKey": "None", "id": 14}, {"name_eng": "Yoga Club", "name_esp": "Club de yoga", "text_eng": "Hear more information about Yoga Club from Ms. Malone!", "name_esp": "¡Escuche más información sobre Yoga Club de la Sra. Malone!",  "imgKey": "None", "id": 15}, {"name_eng": "Poetry At The Peak", "name_esp": "Poesía en la cima", "text_eng": "Hear more information about Poetry At The Peak from Ms. Scoville!", "name_esp": "¡Escuche más información sobre Poetry At The Peak de la Sra. Scoville!",  "imgKey": "None", "id": 16}, {"name_eng": "Wildlife Rangers", "name_esp": "Guardabosques de animales", "text_eng": "Hear more information about Wildlife Rangers from Mr. Freeman!", "name_esp": "¡Escuche más información sobre Wildlife Rangers del Sr. Freeman!",  "imgKey": "None", "id": 17}, {"name_eng": "Garden Club", "name_esp": "Club de jardín", "text_eng": "Hear more information about Garden Club from Mr. Jiron!", "name_esp": "¡Escuche más información sobre Garden Club de Mr. Jiron!",  "imgKey": "None", "id": 18}], "imgKey": "image2.png", "id": 2}, {"name_eng": "Sports", "name_esp": "Los deportes", "text_eng": "Are you interested in joining a sport? Longs Peak is known throughout the district for its sports programs!", "text_esp": "¿Estás interesado en unirte a un deporte? ¡Longs Peak es conocido en todo el distrito por sus programas deportivos!", "profiles": [{"name_eng": "Volleyball", "name_esp": "Vóleibol", "text_eng": "Hear more information about volleyball from Mr. Meehan!", "name_esp": "¡Escuche más información sobre el voleibol del Sr. Meehan!",  "imgKey": "None", "id": 19}, {"name_eng": "Basketball", "name_esp": "Baloncesto", "text_eng": "Hear more information about basketball from Mr. Vandiver!", "name_esp": "¡Escuche más información sobre baloncesto del Sr. Vandiver!",  "imgKey": "None", "id": 20}, {"name_eng": "Wrestling", "name_esp": "Lucha", "text_eng": "Hear more information about wrestling from Mr. Jiron!", "name_esp": "¡Escuche más información sobre la lucha libre del Sr. Jiron!",  "imgKey": "None", "id": 21}, {"name_eng": "Track & Field", "name_esp": "Atletismo", "text_eng": "Hear more information about track and field from Ms. Heien!", "name_esp": "¡Escuche más información sobre atletismo de la Sra. Heien!",  "imgKey": "None", "id": 22}, {"name_eng": "Soccer", "name_esp": "Fútbol", "text_eng": "Hear more information about soccer from Mr. Jiron!", "name_esp": "¡Escuche más información sobre fútbol del Sr. Jiron!",  "imgKey": "None", "id": 23}, {"name_eng": "Cross Country", "name_esp": "Carrera de distancia", "text_eng": "Hear more information about cross country from Mr. Freeman!", "name_esp": "¡Escuche más información sobre el campo traviesa del Sr. Freeman!",  "imgKey": "None", "id": 24}], "imgKey": "image4.png", "id": 3}, {"name_eng": "School Tour", "name_esp": "Excursión escolar", "text_eng": "Curious about what the halls of Longs Peak look like? Come take a tour!", "text_esp": "¿Tienes curiosidad por saber cómo son los pasillos de Longs Peak? ¡Ven a hacer un recorrido!", "profiles": [{"name_eng": "School Tour", "name_esp": "Excursión escolar", "text_eng": "", "name_esp": "",  "imgKey": "None", "id": 25}], "imgKey": "None", "id": 4}, {"name_eng": "Videos", "name_esp": "Videos", "text_eng": "Learn more about what makes Longs Peak amazing!", "text_esp": "¡Aprenda más sobre lo que hace que Longs Peak sea increíble!", "profiles": [{"name_eng": "School Tour", "name_esp": "Excursión escolar", "text_eng": "Curious about what the halls of Longs Peak look like? Come take a tour!", "name_esp": "¿Tienes curiosidad por saber cómo son los pasillos de Longs Peak? ¡Ven a hacer un recorrido!",  "imgKey": "None", "id": 26}, {"name_eng": "Welcome to Longs Peak", "name_esp": "Bienvenido a Longs Peak", "text_eng": "Listen to our Principal, Mrs. Heiser, explain why Longs Peak is such an special place to be!", "name_esp": "Escuche a nuestra directora, la Sra. Heiser, ¡explicar por qué Longs Peak es un lugar tan especial para estar!",  "imgKey": "None", "id": 29}, {"name_eng": "Welcome to Longs Peak", "name_esp": "Bienvenido a Longs Peak", "text_eng": "Listen to our Principal, Mrs. Heiser, explain why Longs Peak is such an special place to be!", "name_esp": "Escuche a nuestra directora, la Sra. Heiser, ¡explicar por qué Longs Peak es un lugar tan especial para estar!",  "imgKey": "None", "id": 30}], "imgKey": "image1.png", "id": 5}], "imgKey": "Screen_Shot_2021-04-18_at_8.22.24_PM.png", "id": 1}, {"name": "testing", "categories": [{"name_eng": "Teacher", "name_esp": "", "text_eng": "These are the teachers in the building", "text_esp": "", "profiles": [{"name_eng": "BC", "name_esp": "", "text_eng": "Teacher", "name_esp": "",  "imgKey": "cerroneSmall.jpg", "id": 27}, {"name_eng": "James", "name_esp": "", "text_eng": "", "name_esp": "",  "imgKey": "cave.png", "id": 28}], "imgKey": "image5.png", "id": 6}], "imgKey": "IMG_0595.jpg", "id": 2}]
