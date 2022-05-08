//
//  SecondViewController.swift
//  NatureBook
//
//  Created by Şükrü Özkoca on 7.05.2022.
//

import UIKit
import CoreData

class SecondViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var yearTextfield: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var placeTextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var targetName = ""
    var targetId:UUID?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 9
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.cgColor
         
        if targetName != "" {
            self.saveButton.isHidden = true
            //CoreData Verileri buraya gelecek
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
            //Filtreleme
            let idString = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
               let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameTextfield.text = name
                    }
                    if let place = result.value(forKey: "place") as? String {
                        placeTextfield.text = place
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearTextfield.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        imageView.image = image
                                            
                    }
                    
                    
                }
            }
            catch{
                print("Error")
            }
            
            
        }
        else {
            
        }

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        //Veri Kaydetme İşlemi
        let appDelegate = UIApplication.shared.delegate as!  AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Gallery", into: context)
        saveData.setValue(nameTextfield.text!, forKey: "name")
        saveData.setValue(placeTextfield.text!, forKey: "place")
        if let year = Int(yearTextfield.text!){
            saveData.setValue(year, forKey: "year")
        }
        let imagePress = imageView.image?.jpegData(compressionQuality: 0.5)
        saveData.setValue(imagePress, forKey: "image")
        saveData.setValue(UUID(), forKey: "id")
        do {
            try context.save()
            print("Successs")
        }
        catch {
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func imageTap() {
        let picker  = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}
