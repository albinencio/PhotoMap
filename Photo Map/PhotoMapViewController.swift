//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Alberto Nencioni on 03/07/18.
//  Copyright © 2018 Alberto Nencioni. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, LocationsViewControllerDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var cameraButton: UIButton!
  
  var image: UIImage!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    cameraButton.layer.cornerRadius = 50
    
    let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                          MKCoordinateSpanMake(0.1, 0.1))
    mapView.setRegion(sfRegion, animated: false)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func onCamera(_ sender: Any) {
    let vc = UIImagePickerController()
    vc.delegate = self
    vc.allowsEditing = true
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      print("Camera is available 📸")
      vc.sourceType = .camera
    } else {
      print("Camera 🚫 available so we will use photo library instead")
      vc.sourceType = .photoLibrary
    }
    
    self.present(vc, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
    // Get the image captured by the UIImagePickerController
    let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
    self.image = editedImage
    
    // Dismiss UIImagePickerController to go back to your original view controller
    dismiss(animated: true, completion: {
      self.performSegue(withIdentifier: "tagSegue", sender: self)
    })
    
  }
  
  func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
    let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
    let region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(0.1, 0.1))
    mapView.setRegion(region, animated: false)
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinates
    annotation.title = "(\(latitude), \(longitude)"
    mapView.addAnnotation(annotation)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseID = "myAnnotationView"
    
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
    if (annotationView == nil) {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      annotationView!.canShowCallout = true
      annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
    
    let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
    resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
    resizeRenderImageView.layer.borderWidth = 3.0
    resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
    resizeRenderImageView.image = image
    
    UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
    resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
    _ = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    imageView.image = resizeRenderImageView.image
    
    return annotationView
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! LocationsViewController
    destinationVC.delegate = self
    
  }
  
}
