//
//  ViewController.swift
//  Machine Task
//
//  Created by MacBookPro on 02/06/2020.
//  Copyright © 2020 MacBookPro. All rights reserved.
//

import UIKit
import MapKit


let locationURL = "https://myscrap.com/api/msDiscoverPage"      //API with key and searchText
let params = ["apiKey": "501edc9e", "searchText": ""]as Dictionary<String, String>


class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!   //Mapview IBOUTLET to use in future
    let locationManager = CLLocationManager()
    
    var Res = [Results]() //Model class object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true //turn on the user's location
        
        guard let locURL = URL(string: locationURL)
            else {
                return}
        
        callPost(url: locURL, params: params)
        
    }
    func fetchCompaniesOnMap(_ results: [Results]) {
        for res in results {
            let annotations = MKPointAnnotation()
            annotations.title = res.name
            annotations.coordinate = CLLocationCoordinate2D(latitude:
                res.latitude, longitude: res.longitude)
            mapView.addAnnotation(annotations)
        }
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Location is not on...Show an alert message to user.
        }
    }
    
    func checkAuthorizationStatus() {    //Checking authorization status
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: break
        case .denied: break
        case .notDetermined: break
        case .restricted: break
        case .authorizedAlways: break
        }
    }
    
    
    func checkLocationAuthorization() {   //Checking Location Authoriation
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .denied: // Show alert telling users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: // Show an alert letting them know whats going on
            break
        case .authorizedAlways:
            break
        }
    }
    
    func callPost(url:URL, params:[String:Any]) -> Void //Fetch API data and Parsing JSON
    {
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let postString = self.getPostString(params: params)
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        
        var result:(message:String, data:Data?) = (message: "Fail", data: nil)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if(error != nil)
            {
                result.message = "Fail Error not null : \(error.debugDescription)"
            }
            else
            {
                result.message = "Success"
                result.data = data
                do {
                    let json = try JSONSerialization.jsonObject(with: data ?? Data()
                        , options: .allowFragments) as! [String:Any]
                    
                    print(json)
                    let jsonLoc = json["locationData"] as! [AnyObject]
                    for jsonLoc in jsonLoc {
                        
                        var res = Results()
                        res.name = jsonLoc["name"] as! String
                        
                        
                        res.latitude = ( jsonLoc["latitude"] as! NSString).doubleValue
                        res.longitude = ( jsonLoc["longitude"] as! NSString).doubleValue
                        
                        self.Res.append(res)
                        self.fetchCompaniesOnMap([res])
                    }
                    
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            
        }
        task.resume()
        
    }
    func getPostString(params:[String:Any]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    
    
    
}

