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
import Combine


struct WorldMapView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var modalTrackr = ModalTrackr() // tracks whether to show modal
    @ObservedObject var tabTrackr = TabTrackr() // tracks current tab
    @ObservedObject var selection = Selection()
    
    @Environment(\.colorScheme) var colorScheme
    @State var showModal: Bool = false
    @State var currentTab: String = "Cases"
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                MapboxView(viewModel: viewModel, modalTrackr: modalTrackr, tabTrackr: tabTrackr, selection: selection)
                    .padding(2)
                    .sheet(
                        isPresented: $modalTrackr.showModal,
                        content: {
                            ModalView(viewModel: ModalViewModel(country: selection.selectedCountry!))
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.height(500)])
                        })
                VStack() {
                    Spacer()
                    Picker("", selection: $tabTrackr.currentTab) {
                        Text("Cases")
                            .tag("Cases")
                        Text("Deaths")
                            .tag("Deaths")
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background{
                        RoundedRectangle(cornerRadius: 8, style: .continuous )
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
                .frame(minWidth: 0, maxWidth:  200, minHeight: 0, maxHeight: .infinity, alignment: .center)
                .padding(.bottom,30)

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
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        
        }
    }
}
struct MapboxView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var modalTrackr: ModalTrackr
    @ObservedObject var tabTrackr: TabTrackr
    @ObservedObject var selection: Selection
    
    func makeUIViewController(context: Context) -> MapboxViewController {
        return MapboxViewController(
            viewModel: viewModel,
            modalTrackr: modalTrackr,
            tabTrackr: tabTrackr,
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
    private var tabTrackr: TabTrackr
    private var cancellables: Set<AnyCancellable> = []
    private var sourceID: String = "countries"
    
    init(viewModel: DashboardViewModel, modalTrackr: ModalTrackr, tabTrackr: TabTrackr, selection: Selection){
        self.viewModel = viewModel
        self.modalTrackr = modalTrackr
        self.tabTrackr = tabTrackr
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
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            zoom: 0,
            bearing: -7.6,
            pitch: 0)
        let mapInitOptions = MapInitOptions(
            resourceOptions: resourceOptions,
            cameraOptions: cameraOptions,
            styleURI: StyleURI(rawValue: "mapbox://styles/amroncodes/clchndkb5000515pofk3817vo")
        )
        
   
        // Create world map with Mapbox API
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.layer.cornerRadius = 8
        mapView.layer.masksToBounds = true
        // Pass map to WorldMapView
        self.view.addSubview(mapView)
        
        // Run the following when the base map loads
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.addSource()
            // Set up the tap gesture
            self.addTapGesture()
            self.tabTrackr.$currentTab
                .receive(on: RunLoop.main)
                .sink{ (tab) in
                    print("Tab clicked: \(tab)")
                    if tab == "Cases" {
                        self.addCasesData()
                    }else {
                        self.addDeathsData()
                    }
                }.store(in: &self.cancellables)
            
        }
    }
    
    // Add source data for country polygons
    func addSource() {
        // Create the source for country polygons using the Mapbox Countries tileset
        // The polygons contain an ISO 3166 alpha-3 code which can be used to for joining the data
        // https://docs.mapbox.com/vector-tiles/reference/mapbox-countries-v1
        var source = VectorSource()
        source.url = "mapbox://mapbox.country-boundaries-v1"
        
        do {
            try mapView.mapboxMap.style.addSource(source, id: sourceID)
        }catch {
            print("Failed to add source. \nError: \(error.localizedDescription)")
        }
    }
    // Create a data layer (Choropleth) of confirmed COVID-19 cases using the Mapbox Countries tileset
    func addDeathsData() {

        // Add layer from the vector tile source to create the choropleth
        var layer = FillLayer(id: "country_deaths")
        layer.source = self.sourceID
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
        
        // Calculate color values for each country based on 'deaths' value
        var colorValue: Double = 0.0
        var expressionBody: String = ""
        var colorRGB: String = ""
        let max_deaths = 1000000
        
        // Convert the range of data values (countries) to a suitable color
        for country in viewModel.countries {
            // Calculate percentage of max cases
            let ratio = Double(country.stats!.deaths)/Double(max_deaths) * 255 + 20
            
            // Set color value based on the ratio of cases
            colorValue = (ratio > 255) ? 255 : ratio // red
            
            // Generate rgb value for color
            colorRGB = "rgb(255, \(255-colorValue), \(255-colorValue))"
            
            // Extract iso3 of the country to build expression body
            if let iso3 = country.info?.iso3 {
                expressionBody += """
                "\(iso3)",
                "\(colorRGB)",

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

        
        // Try to remove the cases layer
        do {
            try mapView.mapboxMap.style.removeLayer(withId: "country_cases")
            print("Cases layer removed")
        } catch {
            print("Cases layer not found")
        }
        
        // Add the source
        // Insert the vector layer below the 'admin-1-boundary-bg' layer in the style
        // Join data to the vector layer
        do {
            try mapView.mapboxMap.style.addLayer(layer, layerPosition: .below("admin-1-boundary-bg"))
            if let expressionData = jsonExpression.data(using: .utf8) {
                let expJSONObject = try JSONSerialization.jsonObject(with: expressionData, options: [])
                try mapView.mapboxMap.style.setLayerProperty(
                    for: "country_deaths",
                    property: "fill-color",
                    value: expJSONObject
                )
            }
            

        } catch {
            print("Failed to add the data layer. Error: \(error.localizedDescription)")
        }
    }
    
    // Create a data layer (Choropleth) of confirmed COVID-19 cases using the Mapbox Countries tileset
    func addCasesData() {

        // Add layer from the vector tile source to create the choropleth
        var layer = FillLayer(id: "country_cases")
        layer.source = self.sourceID
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

        // Calculate color values for each country based on 'deaths' value
        var colorValue: Double = 0.0
        var expressionBody: String = ""
        var colorRGB: String = ""
        let max_cases = 100000000
        
        // Convert the range of data values (countries) to a suitable color
        for country in viewModel.countries {
            // Calculate percentage of max cases
            let ratio = Double(country.stats!.confirmed)/Double(max_cases) * 255 + 20
            
            // Set color value based on the ratio of cases
            colorValue = (ratio > 255) ? 255 : ratio
            
            // Generate rgb value for color
            colorRGB = "rgb(\(255-colorValue), \(255-colorValue), 255)" // blue
            
            // Extract iso3 of the country to build expression body
            if let iso3 = country.info?.iso3 {
                expressionBody += """
                "\(iso3)",
                "\(colorRGB)",

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

        
        // Try to remove the deaths layer
        do {
            try mapView.mapboxMap.style.removeLayer(withId: "country_deaths")
            print("Deaths layer removed")
        } catch {
            print("Deaths layer not found")
        }
        
        // Add the source
        // Insert the vector layer below the 'admin-1-boundary-bg' layer in the style
        // Join data to the vector layer
        do {
            try mapView.mapboxMap.style.addLayer(layer, layerPosition: .below("admin-1-boundary-bg"))
            if let expressionData = jsonExpression.data(using: .utf8) {
                let expJSONObject = try JSONSerialization.jsonObject(with: expressionData, options: [])
                try mapView.mapboxMap.style.setLayerProperty(
                    for: "country_cases",
                    property: "fill-color",
                    value: expJSONObject
                )
            }
            
        } catch {
            print("Failed to add the data layer. Error: \(error.localizedDescription)")
        }
    }
    
    // Add a tap gesture to the map view.
    func addTapGesture() {
        // Create the tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(findFeatures))
        
        // Add the gesture recognizer to the map view
        self.mapView.addGestureRecognizer(tapGesture)
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
            options: RenderedQueryOptions(layerIds: ["country_cases", "country_deaths"], filter: nil)) {[weak self] result in
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

class TabTrackr: ObservableObject {
    @Published var currentTab: String = "Cases"
}
