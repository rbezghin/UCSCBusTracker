//
//  ViewController.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 1/27/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Mapbox
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections

class ViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MGLMapView(frame: view.frame)
        mapView.delegate = self
        view.addSubview(mapView)
        
    }
    
    //add traking data here
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
    //stop timer if view dissapeared
    override func viewWillDisappear(_ animated: Bool) {
        
    }


}

