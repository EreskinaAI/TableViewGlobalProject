//
//  MapViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 14.02.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var place: Place!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()


    }
    
	@IBAction func closeMap() {
		dismiss(animated: true)
	}
    
    
    // MARK: Display a place on the map
    private func setupPlacemark() {
        guard let location = place.location else {return} //извлекаем адрес
        
        let geocoder = CLGeocoder() // экз-р, кот преобразует адрес в географ.координаты
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error { //  проверка error дожен быть nil
                print(error)
                return
            }
            guard let arrayPlacemarks = placemarks else {return}//извлекаем опционал из массива с метками
            let placemark = arrayPlacemarks.first // получили метку на карте
            
            let annotation = MKPointAnnotation()
            // Описываем точку на карте через annotation
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            //Привязываем annotation к конкрет.точке на карте в связи с локацией маркера
            
            guard let placemarkLocation = placemark?.location else {return}
            //местоположение маркера
            
            annotation.coordinate = placemarkLocation.coordinate
            // привязываем annotation к местоположению маркера
            
            self.mapView.showAnnotations([annotation], animated: true)
            // показываем все annotations на карте
            self.mapView.selectAnnotation(annotation, animated: true)
            // отметка на карте большая подсвечивается
            
            
        }
        
    }
}
