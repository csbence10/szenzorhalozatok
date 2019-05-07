//
//  ViewController.swift
//  Szenzorhalok
//
//  Created by Csondor Bence on 2019. 04. 27..
//  Copyright © 2019. Csondor Bence. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    private let locationManager = CLLocationManager()
    private let meters = 2000.0
    private let turboUrl = "http://152.66.183.29:8090/smartparkingsystem/api/sensordata?"
    var sensorData: ((SensorData) -> ())!
    @IBOutlet weak private var mapView: MKMapView!
    @IBAction private func currentLocationTap(_ sender: Any) {
        centerMap()
    }

    @IBAction func refresh(_ sender: Any) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        getSensorData(from: coordinate) { (sensorData, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                guard let data = sensorData else { return }
                print(data)

                let annotation = SensorAnnotation(title: data.label, subtitle: data.busy ? "Busy" : "Free",
                                                  coordinate: CLLocationCoordinate2D(latitude: data.coordinates.latitude,
                                                                                     longitude: data.coordinates.longitude))
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        mapView.showsUserLocation = true
        
        centerMap()
        checkAuthorizationStatus()
        if let coordinate = locationManager.location?.coordinate {
            getSensorData(from: coordinate) { (sensorData, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    guard let data = sensorData else { return }
                    print(data)
                    let annotation = SensorAnnotation(title: data.label, subtitle: data.busy ? "Busy" : "Free",
                                                      coordinate: CLLocationCoordinate2D(latitude: data.coordinates.latitude,
                                                                                         longitude: data.coordinates.longitude))
                    DispatchQueue.main.async {
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.mapView.addAnnotation(annotation)
                    }
                    print(self.mapView.annotations)
                }
            }
        }

    }
    
    private func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
        case .authorizedWhenInUse:
            locationManager.startMonitoringSignificantLocationChanges()
        default:
            break
        }
    }

    private func centerMap() {
        guard let location = locationManager.location else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: meters,
                                        longitudinalMeters: meters)
        mapView.setRegion(region, animated: true)
    }
    
    private func getSensorData(from coordinate: CLLocationCoordinate2D, result: @escaping (SensorData?, Error?) -> ()) {
        let url = URL(string: turboUrl + "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { return }
            let sensorData = try? JSONDecoder().decode(SensorData.self, from: data)
            result(sensorData,error)
            }.resume()
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        mapView.userTrackingMode = .follow
        getSensorData(from: location.coordinate) { (sensorData, error) in

            if error != nil {
                print(error?.localizedDescription)
            } else {
                guard let data = sensorData else { return }
                let annotation = SensorAnnotation(title: data.label, subtitle: data.busy ? "Busy" : "Free",
                                                  coordinate: CLLocationCoordinate2D(latitude: data.coordinates.latitude,
                                                                                     longitude: data.coordinates.longitude))

                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? SensorAnnotation else { return nil }
        
        let identifier = "annotation"
        var view: MKAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            let button = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                                 size: CGSize(width: 30, height: 30)))
            button.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            view.rightCalloutAccessoryView = button
        }
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Tapped")
        guard let destination = view.annotation?.coordinate else { return }
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        MKMapItem.openMaps(with: [MKMapItem.forCurrentLocation(),mapItem], launchOptions: launchOptions)
    }
}
