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

struct WorldMapView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var modalTrackr = ModalTrackr() // tracks whether to show modal
    @ObservedObject var selection = Selection()
    
    @Environment(\.colorScheme) var colorScheme
    @State var showModal: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                MapboxView(viewModel: viewModel, modalTrackr: modalTrackr, selection: selection)
                    .padding(2)
                    .sheet(
                        isPresented: $modalTrackr.showModal,
                        content: {
                            ModalView(viewModel: ModalViewModel(country: selection.selectedCountry!))
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.height(500)])
                        })
            }
            .padding()
            .navigationTitle("World Map")
            .background{
                RoundedRectangle(cornerRadius: 10, style: .continuous )
                    .fill(
                        Color(UIColor.systemBackground)
                            .shadow(
                                .drop(
                                    color: (colorScheme == .dark) ? Color.white : Color.secondary ,
                                    radius: 2
                                )
                            )
                    ).padding()
            }
        
        }
    }
}
struct MapboxView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var modalTrackr: ModalTrackr
    @ObservedObject var selection: Selection
    
    func makeUIViewController(context: Context) -> MapboxViewController {
        return MapboxViewController(
            viewModel: viewModel,
            modalTrackr: modalTrackr,
            selection: selection
        )
    }
    
    func updateUIViewController(_ uiViewController: MapboxViewController, context: Context) {
        
    }
}

class MapboxViewController: UIViewController {
    internal var mapView: MapView!
    private var viewModel: DashboardViewModel
    private var selection: Selection
    private var modalTrackr: ModalTrackr
    
    init(viewModel: DashboardViewModel, modalTrackr: ModalTrackr, selection: Selection){
        self.viewModel = viewModel
        self.modalTrackr = modalTrackr
        self.selection = selection
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
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Pass map to WorldMapView
        self.view.addSubview(mapView)
        
        // Run the following when the base map loads
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addTileDataLayer()
        }
    }
    
    
    // Create a data layer (Choropleth) using the Mapbox Countries tileset
    func addTileDataLayer() {
        // Sample Data
        struct Country {
            let code: String
            let cases: Int
            let deaths: Int
        }
        let max_cases = 10000000 // Todo: Find max

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
        var colorValue: Double
        var expressionBody: String = ""
        
        // Convert the range of data values (countries) to a suitable color
        for country in viewModel.countries {
            // Calculate percentage of max cases
            let ratio = Double(country.stats!.confirmed)/Double(max_cases) * 255 + 20
            
            // Set color value based on the ratio of cases
            colorValue = (ratio > 255) ? 255 : ratio // red
            
            // Extract iso3 of the country to build expression body
            if let iso3 = country.info?.iso3 {
                expressionBody += """
                "\(iso3)",
                "rgb(255, \(255 - colorValue), \(255 - colorValue))",

                """
            }

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
            try mapView.mapboxMap.style.addSource(source, id: sourceID)
            try mapView.mapboxMap.style.addLayer(layer, layerPosition: .below("admin-1-boundary-bg"))
            if let expressionData = jsonExpression.data(using: .utf8) {
                let expJSONObject = try JSONSerialization.jsonObject(with: expressionData, options: [])
                try mapView.mapboxMap.style.setLayerProperty(
                    for: "countries",
                    property: "fill-color",
                    value: expJSONObject
                )
            }
            
            // Set up the tap gesture
            addTapGesture(to: mapView)
        } catch {
            print("Failed to add the data layer. Error: \(error.localizedDescription)")
        }
    }
    
    // Add a tap gesture to the map view.
    func addTapGesture(to mapView: MapView) {
        // Create the tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(findFeatures))
        
        // Add the gesture recognizer to the map view
        mapView.addGestureRecognizer(tapGesture)
    }
        
    /**
     Use the tap point received from the gesture recognizer to query
     the map for rendered features at the given point within the layer specified.
     */
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        // Get geographic coordinates of the location (point) where the map is tapped
        let tapPoint = sender.location(in: mapView)
        
        // Perform feature querying to extract country data from the tapPoint
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["countries"], filter: nil)) {[weak self] result in
                switch result {
                case.success(let features):
                    // Extract the feature properties from the matching country
                    if let firstFeature = features.first?.feature.properties,
                       case let .string(iso3) = firstFeature["iso_3166_1_alpha_3"] {
                        
                        // Find matching country with iso3
                        if let country = self?.getCountry(iso3: iso3) {
                            // Update selection and trigger modal presentation
                            self?.selection.selectedCountry = country
                            self?.modalTrackr.showModal.toggle()
                        }
                    }
                case .failure(let error):
                    print("Could not present modal upon click")
                    print(error.localizedDescription)
                }
            }
    }
    
    // Returns a country containing the provided iso3
    func getCountry(iso3: String) -> Country? {
        return viewModel
                .countries
                    .first(where: {$0.info?.iso3 == iso3 })
    }
}

class ModalTrackr: ObservableObject {
    @Published var showModal: Bool = false
}
