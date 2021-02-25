//
//  MapViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 14.02.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdenrifier = "" //логич св-во по выбору конкретного segue
   
    var previousLocation: CLLocation? {// предыдущее местоположение пол-ля
        didSet {
            mapManager.startTrackingUserLocation(for: mapView,
                                                 and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
    @IBAction func centerViewInUserLocation() {
        // карта отцентрируется по местоположению пользователя
        
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() { //передаем текущий адрес с карты
        
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
       
    }
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func closeMap() {
        dismiss(animated: true)
    }
    
    
    // MARK: Отображаем заведение на карте
    
    private func setupMapView() {
        // показ карты в зависимости от segue
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdenrifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdenrifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
        
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocationView) else { return nil }
        // тек.метка - это не тек геолокация пользователя
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        //создаем метку в виде банера(по шаблону уже существующих меток, но с идентификатором) и приводим к типу pinAnnotation
        
        if annotationView == nil {// на случай когда нет меток, оформляем свою
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true // банер с инфой
            
        }
        
        // Присваеваем картинку с заведением внутри банера
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView // картинка на банере справа
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // вызов метода каждый раз при смене выбранного региона (адрес в центре тек региона)
        
        let center = mapManager.getCenterLocation(for: mapView)// тек координаты по центру отобр области
        let geocoder = CLGeocoder()
        
        if incomeSegueIdenrifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView) // фокусировка на локации пол-ля
            }
        }
        
        geocoder.cancelGeocode() //  отмена отложенного запроса для высвобождения ресурсов
        
        // Наоборот из координат получаем адрес
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
               print(error)
                return
            }
            guard let arrayPlacemarks = placemarks else { return }
            
            let placemark = arrayPlacemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // рисуем линию маршрута цветом(тк по умолчанию она невидимо наложена)
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}
extension MapViewController: CLLocationManagerDelegate {
    // отслеживает статус авторизации
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView,
                                              segueIdentifier: incomeSegueIdenrifier)
    }
}
