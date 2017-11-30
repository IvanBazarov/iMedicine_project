//
//  MapViewController.swift
//  iMedicine
//
//  Created by Иван Базаров on 03.07.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreLocation



class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    let locationManager = CLLocationManager()
    var zoomLevel: Float = 15.0
    var mapData:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let apiKey = "AIzaSyBJga-Ow00zjl9QBDfeADWrXpNY2mljjp4"
    var pharmacyModels:[PharmacyModel]?
    var mapData2:[PharmacyModel] = []
    var mapData3:[PlaceModel] = []
    var location_marker = GMSMarker()
    var zoom:Float = 0
    var markers_arr = [GMSMarker]()
    var activityIndicatorView: ActivityIndicatorView!
    var _mapTabBarItem: UITabBarItem?
    let radius_inc = 500
    let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    var semaphore_time:UInt64 = DISPATCH_TIME_FOREVER
    var connection_alert_appeared = false
    
    @IBOutlet var mapView: GMSMapView!
    
    
    override func viewWillAppear(animated: Bool) {
    
        super.viewWillAppear(animated)
        self.connection_alert_appeared = false
        
        self.activityIndicatorView = ActivityIndicatorView(title: "Загрузка карты...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        
        self.markers_arr = []
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            
            
            let lat = locationManager.location?.coordinate.latitude
            let lon = locationManager.location?.coordinate.longitude
            
            if (lat != nil && lon != nil)
            {
                mapData.latitude = lat!
                mapData.longitude = lon!
                
                StructOperation.globalVariable.publishData_count = 0
                StructOperation.globalVariable.radius = 0
                
                searchNearbyFarmacy{(publishData) -> Void in
                    
                
                    self.mapData2 = publishData
                    if (publishData.count == 0 && StructOperation.globalVariable.radius == 20 * self.radius_inc) {
                        
                        let alertMessage = UIAlertController(title: "Сервис недоступен", message: "Не удалось найти на одной открытой аптеки рядом с вами", preferredStyle: .Alert)
                        alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alertMessage, animated: true, completion: nil)
                    }
                    
                    if (publishData.count != 0 || StructOperation.globalVariable.radius == 20 * self.radius_inc) {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if (StructOperation.globalVariable.radius == self.radius_inc) {
                                self.zoom = 14
                            }
                            if (StructOperation.globalVariable.radius > self.radius_inc && StructOperation.globalVariable.radius < 3 * self.radius_inc + 1) {
                                self.zoom = 13
                            }
                            if (StructOperation.globalVariable.radius > 3 * self.radius_inc + 1 && StructOperation.globalVariable.radius < 10 * self.radius_inc + 1) {
                                self.zoom = 12
                            }
                            
                            if (StructOperation.globalVariable.radius > 10 * self.radius_inc + 1) {
                                self.zoom = 11
                            }
                            
                            
                            let camera = GMSCameraPosition.cameraWithLatitude(self.mapData.latitude, longitude: self.mapData.longitude, zoom: self.zoom)
                            self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
                            self.view = self.mapView
                            self.mapView.delegate = self
                            
                            for index in 0..<Int((publishData.count)) {
                                
                                let marker_location = CLLocationCoordinate2DMake(publishData[index].lat!, publishData[index].lon!)
                                let marker_test = GMSMarker(position: marker_location)
                                marker_test.title = publishData[index].name
                                marker_test.snippet = publishData[index].address
                                marker_test.icon = UIImage(named: "pin")
                                marker_test.tracksInfoWindowChanges = true
                                self.markers_arr.append(marker_test)
                                
                                marker_test.map = self.mapView
                                
                            }
                        
                        self.activityIndicatorView.stopAnimating()
                            
                        }
                        
                    }
                    
                }
                
                
                locationManager.startUpdatingLocation()
                
                
            } else {
                
                let alertMessage = UIAlertController(title: "Сервис недоступен", message: "Не удалось определить ваше местоположение", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
                self.activityIndicatorView.stopAnimating()
                
            }
            
        }

    
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways{
            locationManager.requestLocation()
        }
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            let location = locations.first
            
            StructOperation.globalVariable.global_lat = (location?.coordinate.latitude)!
            StructOperation.globalVariable.global_lon = (location?.coordinate.longitude)!
            
            self.view = self.mapView
            
            let current_Location = CLLocationCoordinate2DMake(StructOperation.globalVariable.global_lat, StructOperation.globalVariable.global_lon)
            
            
            self.location_marker.position = current_Location
            self.location_marker.title = "Ваше местоположение"
            self.location_marker.snippet = ""
            self.location_marker.icon = UIImage(named: "placeholder")
            self.location_marker.map = self.mapView
            
            
            
 
    
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    

    
    func searchNearbyFarmacy (completion:([PharmacyModel]) -> Void)  {
    

        dispatch_async(backgroundQueue, {
        for index in 1...20 {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                print (index)
            }
            if (StructOperation.globalVariable.publishData_count == 1) {
                
                break
            }
            
            if (StructOperation.globalVariable.publishData_count == 0) {
                
                StructOperation.globalVariable.radius += self.radius_inc
                print ("rad: ",StructOperation.globalVariable.radius)
            }
            
        let semaphore = dispatch_semaphore_create(0)
        
        let dynamicURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.mapData.latitude),\(self.mapData.longitude)&radius=\(StructOperation.globalVariable.radius)&sensor=true&key=\(self.apiKey)&type=pharmacy&language=ru"
        let url = NSURL(string: dynamicURL )
        
            
        NSURLSession.sharedSession().dataTaskWithURL(url!) { ( data, response, error) in
        
            
            if (response == nil) {
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (!self.connection_alert_appeared) {
                    
                        let alertMessage = UIAlertController(title: "Не удалось загрузить данные", message: "Проверьте подключение к интернету", preferredStyle: .Alert)
                        alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alertMessage, animated: true, completion: nil)
                        
                        self.activityIndicatorView.stopAnimating()
                        
                        self.connection_alert_appeared = true
                    
                    }
                    
                    
                })
                
                self.semaphore_time = 1000
                StructOperation.globalVariable.publishData_count = 1
                
            }
            var publishData:[PharmacyModel] = []
            if (data?.length>81)  {
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                let datas =  json.valueForKey("results")! as! NSArray
                
                for dictData : AnyObject in datas{
                    
                    let pharmacyModel = PharmacyModel()
                    let dictEach = dictData as! NSDictionary;
                    let name = dictEach.valueForKey("name")! as! String;
                    pharmacyModel.name = name
                    
                    let placeID = dictEach.valueForKey("place_id")! as! String;
                    pharmacyModel.placeID = placeID
                    
                    let gematries = dictEach.valueForKey("geometry")! as! NSDictionary;
                    let locations:AnyObject = gematries.valueForKey("location")!;
                    let lon = locations.valueForKey("lng")! as! Double;
                    pharmacyModel.lon = lon
                    let lat = locations.valueForKey("lat")! as! Double;
                    pharmacyModel.lat = lat
                    
                    let address = dictEach.valueForKey("vicinity")! as! String;
                    pharmacyModel.address = address
                    
                    let opening_hours = dictEach.valueForKey("opening_hours") as? NSDictionary
                    let open_now = opening_hours?.valueForKey("open_now") as? Bool
                    pharmacyModel.open_now = open_now
                    
                    publishData.append(pharmacyModel)
    
                }
                
                if (publishData.count > 1 || StructOperation.globalVariable.radius == self.radius_inc * 20) {
                    StructOperation.globalVariable.publishData_count = 1
                    completion(publishData)
                    
                }
                
                
            } catch let jsonError {
                print(jsonError)
            }

                
            }
        
            if (StructOperation.globalVariable.radius == self.radius_inc * 20) {
                StructOperation.globalVariable.publishData_count = 1
                completion(publishData)
            }
        

            dispatch_semaphore_signal(semaphore)
        
            }.resume()
            dispatch_semaphore_wait(semaphore, self.semaphore_time)
            
            
     }
        })
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        return false
    }
    
    
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let customInfoWindow1 = NSBundle.mainBundle().loadNibNamed("MarkerInfoView", owner: self, options: nil)[0] as! MarkerInfoView
        let customInfoWindow2 = NSBundle.mainBundle().loadNibNamed("LocationView", owner: self, options: nil)[0] as! LocationView
        
        var selected_window = true
        
        if let index = markers_arr.indexOf(marker) {

            customInfoWindow1.NameLabel.text? = markers_arr[index].title!
            customInfoWindow1.AdressLabel.text? = markers_arr[index].snippet!
    

            if self.mapData2 != [] {
                
                if (self.mapData2[index].open_now == nil) {
                    customInfoWindow1.IfOpenLabel.textColor = UIColor.darkGrayColor()
                    customInfoWindow1.IfOpenLabel.text? = "[Нет данных]"
                }
                if (self.mapData2[index].open_now == true) {
                    customInfoWindow1.IfOpenLabel.textColor = UIColor.greenColor()
                    customInfoWindow1.IfOpenLabel.text? = "[Открыто]"
                }
                if (self.mapData2[index].open_now == false) {
                    customInfoWindow1.IfOpenLabel.textColor = UIColor.redColor()
                    customInfoWindow1.IfOpenLabel.text? = "[Закрыто]"
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                getPlaceInfo(self.mapData2[index].placeID!) {(publishData) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue()){
                        
                        
                        customInfoWindow1.self.TelephoneNumberLabel.text = publishData[0].telephone_number
                        customInfoWindow1.self.WebsiteAddrLabel.text = publishData[0].website
                        
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        if (publishData[0].telephone_number == nil) {
                            customInfoWindow1.self.TelephoneNumberLabel.text = "Телефон отсутствует"
                            
                        }
                        if (publishData[0].website == nil) {
                            customInfoWindow1.self.WebsiteAddrLabel.text = "Web адрес отсутствует"
                            
                        }
                        
                    }
                    
                }
                
            }

        
            
        } else {
            
            selected_window = false
        }
        
        switch  selected_window {
        case true:
            return customInfoWindow1
        case false:
            return customInfoWindow2
            
        }
    
    }
    
    func getPlaceInfo(place_ID: String, completion:([PlaceModel]) -> Void) {
        
        
        let dynamicURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_ID)&key=\(self.apiKey)"
        let url = NSURL(string: dynamicURL )
        
        NSURLSession.sharedSession().dataTaskWithURL(url!) { ( data, response, error) in
            
            if (response == nil) {
                
                let alertMessage = UIAlertController(title: "Не удалось загрузить данные", message: "Проверьте подключение к интернету", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
            }
            if (data?.length>0)  {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                    let status = json.valueForKey("status") as! String
                    
                    
                    if (status == "OK" ) {
                        StructOperation.globalVariable.publishData_count = 1
                    }
                    
                    
                    var publishData:[PlaceModel] = []
                  
                        let datas = json.valueForKey("result") as! NSDictionary
    
                        let placeModel = PlaceModel()
                        let tel_number = datas.valueForKey("international_phone_number") as? String;
                        placeModel.telephone_number = tel_number
                        let website = datas.valueForKey("website") as? String;
                        placeModel.website = website
                        
                        publishData.append(placeModel)
                    
                    completion(publishData)
                    
                    } catch let jsonError {
                    print(jsonError)
                }
            }
          
            }.resume()
 
    }
    
    
}







