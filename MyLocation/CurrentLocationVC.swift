//
//  FirstViewController.swift
//  MyLocation
//
//  Created by Khoa on 9/7/16.
//  Copyright © 2016 Khoa. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var latitudeLbl: UILabel!
    @IBOutlet weak var getLocationBtn: UIButton!
    @IBOutlet weak var addresslbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var longtitudeLbl: UILabel!
    
    let locationManger = CLLocationManager()
    var location : CLLocation?
    var updateLocation = false
    var lastError : NSError?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        updateLabels()
        configureButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func startLocationManger(){
        if CLLocationManager.locationServicesEnabled(){
            // 3 lines of codes to get started!!!
            locationManger.delegate = self
            locationManger.desiredAccuracy =  kCLLocationAccuracyNearestTenMeters
            locationManger.startUpdatingLocation()
            updateLocation = true
        }
    }
    func stopLocationManger(){
        if updateLocation{
            locationManger.stopUpdatingLocation()
            locationManger.delegate = nil
            updateLocation = false
        }
        updateLabels()
        
    }
    func updateLabels(){
        if let location = location{
            latitudeLbl.text = String(format: "%.8f",  location.coordinate.latitude)
            longtitudeLbl.text = String(format: "%.8f", location.coordinate.longitude)
            
        }else{
            latitudeLbl.text = ""
            longtitudeLbl.text = ""
            
            var statusString : String
            if let error = lastError{
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue{
                    statusString = "Location Services Denied"
                }else{
                    statusString = "Unknown Error"
                }
            }
            // disable location on device ( for all apps )
            else if !CLLocationManager.locationServicesEnabled(){
                    statusString = "Location Service Unenabled"
                }else if updateLocation {
                    statusString = "Searching...."
                }else{
                    statusString = "Tag Get Location to get locations"
                }
                
            messageLbl.text = statusString
        }
        
    }
    
    func configureButton(){
        if updateLocation{
            getLocationBtn.setTitle("Stop", for: .normal)
        }else{
            getLocationBtn.setTitle("Get Location", for: .normal)
        }
    }
    // MARK: - Button Action
    @IBAction func getLocation(_ sender: AnyObject) {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined  {
            self.locationManger.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .restricted || authStatus ==  .denied {
            //showTurnOnLocaitonAlert()
            self.locationManger.requestWhenInUseAuthorization()
            return
        }
        if updateLocation{
            stopLocationManger()
        }else{
            lastError = nil
            location = nil
            startLocationManger()
        }
        updateLabels()
        configureButton()
    }
    
    func showTurnOnLocaitonAlert(){
        let alert = UIAlertController(title: "My Location", message: "Turn on Locaiton to use this app", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error : \(error)")
        
        if let error = error as? NSError{
            if error.code == CLError.locationUnknown.rawValue{
                return
            }
            // if there are more serious error happens
            lastError = error
            
            // stops when see errors
            stopLocationManger()
            updateLabels()
            configureButton()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("the location is : \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        // if location (past) accuracy < newLocation => GO ON
        if location == nil || (location?.horizontalAccuracy)! > newLocation.horizontalAccuracy{
            lastError = nil
            location = newLocation
            updateLabels()
        }
        if newLocation.horizontalAccuracy <= locationManger.desiredAccuracy  {
            stopLocationManger()
            configureButton()
            print("Stop location manger")
        }
        
    }

}

