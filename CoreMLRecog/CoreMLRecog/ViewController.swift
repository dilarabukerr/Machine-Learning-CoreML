//
//  ViewController.swift
//  CoreMLRecog
//
//  Created by Dilara Büker on 9.05.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeBtn(_ sender: Any) {
        //Foroğeaf seçiciyi başlat.
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Seçilen görüntüyü imageView'a ata
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        //CIImage'e dönüştür:
        /*
         CIImage, Core Image framework tarafından temsil edilen bir görüntü veri yapısıdır. Core Image, görüntü işleme işlemlerini gerçekleştirmek için kullanılan güçlü bir çerçevedir. CIImage, görüntülerin işlenmesi ve manipülasyonu için kullanılır.
         */
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        //Görüntüyü tanıma.
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage (image: CIImage) {
        
        // 1) Request
        // 2) Handler
        
        //Model kullanarak görüntüyü tanı
        resultLabel.text = "Finding..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest,error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int (confidenceLevel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
        
    }
    
}

