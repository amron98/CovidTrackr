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
    @State var choice: String = "Cases"
    @ObservedObject var viewModel: DashboardViewModel
    
    func makeUIViewController(context: Context) -> WorldMapViewController {
        return WorldMapViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: WorldMapViewController, context: Context) {
        
    }
}

class WorldMapViewController: UIViewController {
    internal var worldMapView: MapView!
    private var viewModel: DashboardViewModel

    
    init(viewModel: DashboardViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        // Run the following when the base map loads
        worldMapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addJSONDataLayer()
        }
    }
    
    
    // Create a data layer (Choropleth) using the Mapbox Countries tileset
    func addJSONDataLayer() {
        // Sample Data
        struct Country {
            let code: String
            let cases: Int
            let deaths: Int
        }
        let max_cases = 8000000
        let countries = [
            Country(code: "ROU", cases: 423523, deaths: 4235),
            Country(code: "RUS", cases: 3253663, deaths: 32536),
            Country(code: "SRB", cases: 2352356, deaths: 23523),
            Country(code: "SVK", cases: 2155234, deaths: 21552),
            Country(code: "SVN", cases: 235235, deaths: 2352),
            Country(code: "ESP", cases: 757543, deaths: 7575),
            Country(code: "SWE", cases: 75767, deaths: 757),
            Country(code: "CHE", cases: 58799, deaths: 587),
            Country(code: "HRV", cases: 12345, deaths: 123),
            Country(code: "CZE", cases: 523647, deaths: 5236),
            Country(code: "DNK", cases: 3247437, deaths: 32474),
            Country(code: "EST", cases: 7435356, deaths: 74353),
            Country(code: "FIN", cases: 398436, deaths: 3984),
            Country(code: "FRA", cases: 346697, deaths: 3466),
            Country(code: "DEU", cases: 7283589, deaths: 72835),
            Country(code: "GRC", cases: 92853, deaths: 928),
            Country(code: "ALB", cases: 903256, deaths: 9032),
            Country(code: "AND", cases: 464373, deaths: 4739),
            Country(code: "AUT", cases: 685757, deaths: 6735),
            Country(code: "BLR", cases: 2935235, deaths: 23523),
            Country(code: "BEL", cases: 93953, deaths: 1245),
            Country(code: "BIH", cases: 7943654, deaths: 79436)
        ]

        // Create the source for country polygons using the Mapbox Countries tileset
        // The polygons contain an ISO 3166 alpha-3 code which can be used to for joining the data
        // https://docs.mapbox.com/vector-tiles/reference/mapbox-countries-v1
        let sourceID = "countries"
        var source = VectorSource()
        source.url = "mapbox://mapbox.country-boundaries-v1"
        
        // Add layer from the vector tile source to create the choropleth
        var layer = FillLayer(id: "countries")
        layer.source = sourceID
        layer.sourceLayer = "country_boundaries"
        
        // Build a GL match expression that defines the color for every vector tile feature
        // https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/#match
        // Use the ISO 3166-1 alpha 3 code as the lookup key for the country shape
        let expressionHeader =
            """
            [
            "match",
            ["get", "iso_3166_1_alpha_3"],

            """

        // Calculate color values for each country based on 'cases' value
        var red: Double
        var expressionBody: String = ""
        for country in countries {
            // Calculate percentage of max cases
            let ratio = Double(country.cases)/Double(max_cases) * 255 + 20
            // Convert the range of data values to a suitable color
            red = (ratio > 255) ? 255 : ratio
            
            expressionBody += """
            "\(country.code)",
            "rgb(255, \(255 - red), \(255 - red))",

            """
        }

        // Last value is the default, used where there is no data
        let expressionFooter =
            """
            "rgba(0, 0, 0, 0)"
            ]
            """

        // Combine the expression strings into a single JSON expression
        // You can alternatively translate JSON expressions into Swift: https://docs.mapbox.com/ios/maps/guides/styles/use-expressions/
        let jsonExpression = expressionHeader + expressionBody + expressionFooter

        // Add the source
        // Insert the vector layer below the 'admin-1-boundary-bg' layer in the style
        // Join data to the vector layer
        do {
            try worldMapView.mapboxMap.style.addSource(source, id: sourceID)
            try worldMapView.mapboxMap.style.addLayer(layer, layerPosition: .below("admin-1-boundary-bg"))
            if let expressionData = jsonExpression.data(using: .utf8) {
                let expJSONObject = try JSONSerialization.jsonObject(with: expressionData, options: [])
                try worldMapView.mapboxMap.style.setLayerProperty(for: "countries",
                                                           property: "fill-color",
                                                           value: expJSONObject)
            }
        } catch {
            print("Failed to add the data layer. Error: \(error.localizedDescription)")
        }
    }
}

