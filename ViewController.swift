//
//  ViewController.swift
//  Fare Calculator
//
//  Created by Gaurav Lath on 2016-01-05.
//  Copyright © 2016 Gaurav Lath. All rights reserved.
//

import UIKit



//Added a comma and added CLLocationManagerDelegate. This is needed to give the location
//we must check the authorization status of the app using a special delegate method of the CLLocationManagerDelegate
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //GMSMapView is a predefined class from the GoogleMaps framework
    @IBOutlet var viewMap: GMSMapView!
    @IBOutlet var bbFindAddress: UIBarButtonItem!
    @IBOutlet var lblInfo: UILabel!
    @IBOutlet var dollarButton: UIButton!
    
    // ? when we dont know if we will get a value at runtime but has to be double typed
    // ! means that we will definitely get a double type value as defined during runtime
    var basefare: Double?
    var perkmcharge: Double?
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var mapTasks = MapTasks()
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!
    var markersArray: Array<GMSMarker> = []
    var waypointsArray: Array<String> = []
    
    //    var locationMarker: GMSMarker!
    
    @IBAction func calculateButton(sender: AnyObject) {
        
        if mapTasks.totalDistanceInMeters <= 0 {
            showAlertWithMessage("Please select locations first")
            return
        }
        
        if perkmcharge == nil  ||  basefare == nil {
            showAlertWithMessage("Please select vehicle type")
            return
        }
        
    //    print(perkmcharge)
    //    print(basefare)
    //    print(mapTasks.totalDistance)
        
        let finalCharge: Double
        finalCharge = (Double(mapTasks.totalDistanceInMeters/1000) * perkmcharge!)+basefare!
        
        let alertController = UIAlertController(title: "Result", message: "Estimated charge is: \(finalCharge)", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        
        if locationMarker != nil {
            locationMarker.map = nil
        }
        
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = viewMap
        
        locationMarker.title = mapTasks.fetchedFormattedAddress
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        locationMarker.opacity = 0.75
        
        locationMarker.flat = true
        locationMarker.snippet = "The best place on earth."
    }
    
    
    // The locationManager property will be used to ask for the user’s permission
    // to keep track of his location, and then based on the authorization status
    // to either display his current location or not. The didFindMyLocation flag
    // will be used a bit later, so we know whether the user’s current position was
    // spotted on the map or not, and eventually to avoid unnecessary location updates.
    //    var locationManager = CLLocationManager()
    //    var didFindMyLocation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Creates an object type GMSCameraPosition called camera. cameraWithLatitude
        // function is predefined and calls the location. viewMap.camera sets the camera location.
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(43.4643, longitude: -80.5204, zoom: 16.0)
        viewMap.camera = camera
        
        //Note that the kind of request asked at this point must match to the kind
        //of request we added to the .plist file. By making a call to the
        //requestWhenInUseAuthorization() method of the location manager object,
        //either the user will be presented with an alert view asking for his
        //permission to track his current location if the app runs for first time,
        //or the system will return his preference that was specified at an earlier time.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // This code finds the location and sets an observer to monitor the position
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    // The function runs when authorization is granted by the user
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            viewMap.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            viewMap.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            viewMap.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    /*
    
    @IBAction func findAddress(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address?"
        }
        
        let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let address = (addressAlert.textFields![0] ).text
            
            self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                if !success {
                    print(status)
                    
                    if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage("The location could not be found.")
                    }
                    
                }
                else {
                    let coordinate = CLLocationCoordinate2D(latitude: self.mapTasks.fetchedAddressLatitude, longitude: self.mapTasks.fetchedAddressLongitude)
                    self.viewMap.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                    
                    self.setuplocationMarker(coordinate)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
        
        
    }
    
    
    
    */
    func showAlertWithMessage(message: String) {
        let alertController = UIAlertController(title: "Fare Calculator", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel)
        {
            (alertAction) -> Void in
        }
        alertController.addAction(closeAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func createRoute(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Whenever an alert is created an a text field is added the compiler creates an internal array
        
        addressAlert.addTextFieldWithConfigurationHandler
        {
            (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler
        {
            (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if let _ = self.routePolyline {
                
                self.clearRoute()
                self.waypointsArray.removeAll(keepCapacity: false)
            }
            
            // Whenever an alert is created an a text field is added the compiler creates an internal array
            // 0th index contains the origin 1st index contains the destination
            // so we are taking the text field and extracting its text and saving it in a new variable
            let origin = (addressAlert.textFields![0] as UITextField).text
            let destination = (addressAlert.textFields![1] as UITextField).text
            
            //
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    print(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func changeTravelMode(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Vehicle Type", message: "Select vehicle type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let drivingModeAction = UIAlertAction(title: "SUV", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.basefare = 10
            self.perkmcharge = 5
        }
        
        let walkingModeAction = UIAlertAction(title: "Sedan", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.basefare = 8
            self.perkmcharge = 4
        }
        
        let bicyclingModeAction = UIAlertAction(title: "Mini", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.basefare = 5
            self.perkmcharge = 2
            
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(drivingModeAction)
        actionSheet.addAction(walkingModeAction)
        actionSheet.addAction(bicyclingModeAction)
        actionSheet.addAction(closeAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeMapType(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default)
            {
                //(alertAction) this is the return type and decides what will happen on selecting the
                //the particular button
                (alertAction) -> Void in
                //self is needed because we are accessing the object of its own class
                self.viewMap.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default)
            {
                (alertAction) -> Void in
                self.viewMap.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default)
            {
                (alertAction) -> Void in
                self.viewMap.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel)
            {
                (alertAction) -> Void in
                
        }
        
        //These 4 lines add new options to the list
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        // This is used to show the list
    }
    
    
    // This function drops pin at the initial and final point.
    func configureMapAndMarkersForRoute() {
        viewMap.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.viewMap
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
        destinationMarker.title = self.mapTasks.destinationAddress
        
        
        if waypointsArray.count > 0 {
            //waypoint holds the information for giving us the shortest route
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }
    
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = viewMap
    }
    
    
    func displayRouteInfo() {
        lblInfo.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
    }
    
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    
    
    func recreateRoute() {
        if let _ = routePolyline {
            clearRoute()
            
            mapTasks.getDirections(mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, completionHandler: { (status, success) -> Void in
                
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    print(status)
                }
            })
        }
    }
    
    
    // MARK: GMSMapViewDelegate method implementation
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if let _ = routePolyline {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            waypointsArray.append(positionString)
            
            recreateRoute()
        }
    }
    
    
}

