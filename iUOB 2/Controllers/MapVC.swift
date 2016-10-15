//
//  MapVC.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 9/13/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit
import GoogleMaps
import BTNavigationDropdownMenu

class MapVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate {

    // MARK: - Properties
    
    var menuView: BTNavigationDropdownMenu!
    var uobMarkers: [IUOBMarkers] = []
    var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    var firstLocationUpdate = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleAnalytics()
        
        let items = ["Sakheer", "Isa Town"]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[0], items: items as [AnyObject])
        menuView.arrowTintColor = UIColor.black
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            
            if indexPath == 1 {
                
                if self.mapView != nil {
                    self.mapView.camera = GMSCameraPosition.camera(withLatitude: Constants.isaTownLocation.latitude, longitude: Constants.isaTownLocation.longitude, zoom: 16)
                }
            } else {
                if self.mapView != nil {
                    self.mapView.camera = GMSCameraPosition.camera(withLatitude: Constants.sakheerLocation.latitude, longitude: Constants.sakheerLocation.longitude, zoom: 16)
                }
            }
        }
        
        self.navigationItem.titleView = menuView
        
        /* load all points from plist file */
        let path = Bundle.main.path(forResource: "UOBLocations", ofType:"plist")
        let dict = NSDictionary(contentsOfFile:path!)
        
        let locs = dict!["Locations"] as! NSArray
        
        for loc in locs {
            
            let dataDic = loc as! NSDictionary
            
            let title = dataDic["Title"]! as! String
            var description = ""
            if let desc = dataDic["Description"]! as? String {
                description = desc
            }
            let location = dataDic["Location"]! as! String
            let latitude = Double(dataDic["Latitude"]! as! String)
            let longitude = Double(dataDic["Longitude"]! as! String)
            
            uobMarkers.append(IUOBMarkers(position: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), title: title, description: description, location: location))

        }
        
        loadView()
    }
    
    func googleAnalytics() {
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: NSStringFromClass(type(of: self)).components(separatedBy: ".").last!)
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [NSObject : AnyObject])
        }
    }

    override func loadView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: Constants.sakheerLocation.latitude, longitude: Constants.sakheerLocation.longitude, zoom: 16)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.mapType = kGMSTypeHybrid
        self.mapView.delegate = self
        view = mapView
        
        loadMarkers()
    }

    func loadMarkers() {
        
        for uobMarker in uobMarkers {
            
            let marker = GMSMarker()
            marker.position = uobMarker.position
            marker.title = uobMarker.title
            marker.snippet = uobMarker.description
            
           // marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())

            marker.map = mapView

        }
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        firstLocationUpdate = true
        
        if (CLLocationManager.locationServicesEnabled()) {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if firstLocationUpdate {
                self.mapView.camera = GMSCameraPosition.camera(withTarget: locations.last!.coordinate, zoom: 14)
    
                firstLocationUpdate = false
            }
    }

//func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//
//        if firstLocationUpdate {
//            self.mapView.camera = GMSCameraPosition.camera(withTarget: newLocation.coordinate, zoom: 14)
//
//            firstLocationUpdate = false
//        }
//    }
    
    @IBAction func actionButton(_ sender: AnyObject) {
        
        let actionSheet: UIAlertController = UIAlertController(title: "select map type", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let normal: UIAlertAction = UIAlertAction(title: "Normal", style: .default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeNormal
            }
        }
        actionSheet.addAction(normal)
        
        let hybrid: UIAlertAction = UIAlertAction(title: "Hybrid", style: .default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeHybrid
            }
        }
        actionSheet.addAction(hybrid)
        
        let satellite: UIAlertAction = UIAlertAction(title: "Satellite", style: .default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeSatellite
            }
        }
        actionSheet.addAction(satellite)
        
        let terrain: UIAlertAction = UIAlertAction(title: "Terrain", style: .default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeTerrain
            }
        }
        actionSheet.addAction(terrain)
    
        self.present(actionSheet, animated: true, completion: nil)
    }
}
