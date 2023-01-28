//
//  MapView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/28/23.
//
//
//

import SwiftUI
import MapboxMaps

struct WorldMapView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WorldMapViewController {
        return WorldMapViewController()
    }
    
    func updateUIViewController(_ uiViewController: WorldMapViewController, context: Context) {
        
    }
}

class WorldMapViewController: UIViewController {
    internal var worldMapView: MapView!

    override public func viewDidLoad() {
        // Get access token from info.plist
        let accessToken = Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as! String
        
        // Setup map options
        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let mapInitOptions = MapInitOptions(
            resourceOptions: resourceOptions,
            styleURI: StyleURI(rawValue: "mapbox://styles/amroncodes/clchndkb5000515pofk3817vo")
        )
   
        // Create world map with Mapbox API
        worldMapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        worldMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Pass map to WorldMapView
        self.view.addSubview(worldMapView)
    }
}

