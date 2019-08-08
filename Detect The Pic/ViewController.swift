//
//  ViewController.swift
//  Detect The Pic
//
//  Created by zappycode on 6/19/18.
//  Copyright © 2018 Nick Walter. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var resnetModel = Resnet50()
    var imagePicker = UIImagePickerController()
    var results = [VNClassificationObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        imagePicker.delegate = self
        
        if let image = imageView.image {
            processPicture(image: image)
        }
    }
    
    @IBAction func photoTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processPicture(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func processPicture(image:UIImage) {
        if let model = try? VNCoreMLModel(for: resnetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    
                    self.results = Array(results.prefix(20))
                    
                    self.tableView.reloadData()
                    
//                    for result in results {
//                        print("\(result.identifier): \(result.confidence * 50)%")
//                    }
                }
            }
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let result = results[indexPath.row]
        
        let name = result.identifier.prefix(30)
        cell.textLabel?.text = "\(name): \(Int(result.confidence * 100))%"
        return cell
    }

}

