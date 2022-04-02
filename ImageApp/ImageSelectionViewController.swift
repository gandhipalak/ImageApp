//
//  ImageSelectionViewController.swift
//  ImageApp
//
//  Created by Palak Gandhi on 02/04/22.
//

import UIKit
import PhotosUI

class ImageSelectionViewController: UIViewController {
    
    @IBOutlet weak var imagePicker: UIImageView!
    var date: String?
    var location: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectImageAction(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func rotateLeft(_ sender: UIButton) {
        imagePicker.transform = imagePicker.transform.rotated(by: CGFloat(Double.pi))
    }
    
    @IBAction func rotateRight(_ sender: UIButton) {
        imagePicker.transform = imagePicker.transform.rotated(by: -CGFloat(Double.pi*1.5))
    }
    
    @IBAction func cropImage(_ sender: UIButton) {
         
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! EXIFDetailsViewController
        
        dest.loadView()
        if let date = date , let location = location {
            dest.dateLabel.text = "Date: \(String(describing: date))"
            dest.locationLabel.text = "Location: \(String(describing: location))"
            dest.locationLabel.numberOfLines = 0
            dest.dateLabel.numberOfLines = 0
        } else {
            dest.dateLabel.text = "Date: No Date"
            dest.locationLabel.text = "Location: No Location"
            dest.locationLabel.numberOfLines = 0
            dest.dateLabel.numberOfLines = 0
        }
    }
 
}

extension ImageSelectionViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imagePicker.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imagePicker.image == previousImage else { return }
                    self.imagePicker.image = image
                }
            }
            
            let imageResult = results[0]
            if let assetId = imageResult.assetIdentifier {
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                
                if let imageDate = assetResults.firstObject?.creationDate, let imageLocation = assetResults.firstObject?.location?.coordinate {
                    date = "\(imageDate)"
                    location = "\(imageLocation)"
                } else {
                    date = "No Date"
                    location = "No Location"
                }
            }
        }
    }
}
