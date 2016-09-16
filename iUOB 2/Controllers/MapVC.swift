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
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[0], items: items)
        menuView.arrowTintColor = UIColor.blackColor()
        
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            
            if indexPath == 1 {
                
                if self.mapView != nil {
                    self.mapView.camera = GMSCameraPosition.cameraWithLatitude(Constants.isaTownLocation.latitude, longitude: Constants.isaTownLocation.longitude, zoom: 16)
                }
            } else {
                if self.mapView != nil {
                    self.mapView.camera = GMSCameraPosition.cameraWithLatitude(Constants.sakheerLocation.latitude, longitude: Constants.sakheerLocation.longitude, zoom: 16)
                }
            }
        }
        
        self.navigationItem.titleView = menuView

        /* load all points from plist file */
        let path = NSBundle.mainBundle().pathForResource("UOBLocations", ofType:"plist")
        let dict = NSDictionary(contentsOfFile:path!)
        
        let locs = dict!["Locations"] as! NSArray
        
        for loc in locs {
            
            let title = loc["Title"]! as! String
            var description = ""
            if let desc = loc["Description"]! as? String {
                description = desc
            }
            let location = loc["Location"]! as! String
            let latitude = Double(loc["Latitude"]! as! String)
            let longitude = Double(loc["Longitude"]! as! String)
            
            uobMarkers.append(IUOBMarkers(position: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), title: title, description: description, location: location))

        }
        
        loadView()
    }
    
    func googleAnalytics() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func loadView() {
        
        let camera = GMSCameraPosition.cameraWithLatitude(Constants.sakheerLocation.latitude, longitude: Constants.sakheerLocation.longitude, zoom: 16)
        mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        mapView.myLocationEnabled = true
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

    func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {

        if firstLocationUpdate {
            self.mapView.camera = GMSCameraPosition.cameraWithTarget(newLocation.coordinate, zoom: 14)

            firstLocationUpdate = false
        }
    }
    
    @IBAction func actionButton(sender: AnyObject) {
        
        let actionSheet: UIAlertController = UIAlertController(title: "select map type", message: "", preferredStyle: .ActionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let normal: UIAlertAction = UIAlertAction(title: "Normal", style: .Default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeNormal
            }
        }
        actionSheet.addAction(normal)
        
        let hybrid: UIAlertAction = UIAlertAction(title: "Hybrid", style: .Default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeHybrid
            }
        }
        actionSheet.addAction(hybrid)
        
        let satellite: UIAlertAction = UIAlertAction(title: "Satellite", style: .Default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeSatellite
            }
        }
        actionSheet.addAction(satellite)
        
        let terrain: UIAlertAction = UIAlertAction(title: "Terrain", style: .Default) { action -> Void in
            
            if self.mapView != nil {
                
                self.mapView.mapType = kGMSTypeTerrain
            }
        }
        actionSheet.addAction(terrain)
    
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}
