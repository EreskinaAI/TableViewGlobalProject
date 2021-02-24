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
    func getAddress(_address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager() // экз. класса по настройке и упр-ю службами геолокации
    let regionInMeters = 1000.00
    var incomeSegueIdenrifier = "" //логич св-во по выбору конкретного segue
    var directionsArray: [MKDirections] = [] // массив для хранения маршрутов (предыдущих и новых)
    var previousLocation: CLLocation? {// предыдущее местоположение пол-ля
        didSet {
            startTrackingUserLocation()
        }
    }
    var placeCoordinate:CLLocationCoordinate2D? // координаты заведения
    
    
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
        checkLocationServices()
    }
    
    @IBAction func centerViewInUserLocation() {
        // карта отцентрируется по местоположению пользователя
        
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(_address: addressLabel.text)
        //передаем текущий адрес с карты 
        
        dismiss(animated: true)
    }
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    @IBAction func closeMap() {
        dismiss(animated: true)
    }
    
    
    // MARK: Отображаем заведение на карте
    
    private func setupMapView() {
        // показ карты в зависимости от segue
        
        goButton.isHidden = true
        
        if incomeSegueIdenrifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
        
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        // сбрасываем старые маршруты перед построением новых(если пол-ль движется)
        
        mapView.removeOverlays(mapView.overlays)// удаляем наложение тек маршрута с карты
        directionsArray.append(directions)// добавляем тек маршруты в массив
        let _ = directionsArray.map { $0.cancel() } //перебираем все элементы в массиве и отменяем маршруты
        directionsArray.removeAll()
    }
   
    
   
    
    private func setupPlacemark() {
        guard let location = place.location else {return} //извлекаем адрес
        
        let geocoder = CLGeocoder() // экз-р, кот преобразует адрес в географ.координаты
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error { //  проверка error дожен быть nil
                print(error)
                return
            }
            guard let arrayPlacemarks = placemarks else {return}//извлекаем опционал из массива с метками
            let placemark = arrayPlacemarks.first // получили метку(булавка) на карте
            
            let annotation = MKPointAnnotation()
            // Описываем точку на карте через annotation
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            //Привязываем annotation к конкрет.точке на карте в связи с локацией метки(булавки)
            
            guard let placemarkLocation = placemark?.location else { return }
            // местоположение булавки
            
            annotation.coordinate = placemarkLocation.coordinate
            // привязываем annotation к местоположению булавки
            
            self.placeCoordinate = placemarkLocation.coordinate
            // координаты заведения-это и есть булавка
            
            self.mapView.showAnnotations([annotation], animated: true)
            // показываем все annotations на карте
            
            self.mapView.selectAnnotation(annotation, animated: true)
            // отметка на карте большая подсвечивается
            
            
        }
        
    }
    private func checkLocationServices() {
        // включены ли службы геолокации, a если нет - вызов alert controller
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // отложить выполнение задачи на 1 сек после viewDidLoad
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go: Settings -> Privacy -> Location services and turn on")
            }
        }
    }
    
    private func setupLocationManager() {
        // перв.настройки для установки геолокации
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // высокоточное опр-е местоположения пользователя
        
        
        
    }
    
    private func checkLocationAuthorization() {
        // проверка статуса на разрешение использования геопозиции
        // возвращает 5 основных состояний авторизации для геолокации
        
        switch CLLocationManager().authorizationStatus {
        case .authorizedWhenInUse: // в момент исп-я
            mapView.showsUserLocation = true
            if incomeSegueIdenrifier == "getAddress" { showUserLocation() }
            break
        case .denied:// запрещено использовать геолокацию либо они отключены в настройках
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // метод упр-я запуска c отсрочкой
                self.showAlert(title: "Your location isn't available",
                               message: "To give permission go to: Settings -> TableViewGlobalProject -> Location")
            }
            break
        case.notDetermined: // польз-ль не выбрал давать ли разрешение на свою геолокацию
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: //приложение не авторизовано для служб геолокации
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case is available")
        }
        
    }
    private func showUserLocation() {
        // Показывает тек местоположению полользователя
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            //  прямоугольник с радиусом в районе с заданными долготой и шириной
            
            mapView.setRegion(region, animated: true)
           
        }
    }
    
    private func startTrackingUserLocation() {
        
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)// тек координаты центра отображ области
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center // пред координаты - это тек центр
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // задержка на 3 сек показа тек локации пол-ля
            self.showUserLocation()
        }
    }
    
//    MARK: Логика по прокладке маршрута от локации польз-ля до заведения
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else { // координаты пол-ля
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()// постоянное отслеживание тек локации пол-ля
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            // запрос на прокладку маршрута от положения пол-ля
            
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request) //создаем маршрут на основании сведений из запроса
        resetMapView(withNew: directions) // избавляемся от тек маршрутом перед созданием нового
        
        directions.calculate { (response, error) in
            //расчет маршрута
            
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            for route in response.routes { // перебиранем все маршруты (детали)
                self.mapView.addOverlay(route.polyline)//  накладываем геометрию(прорисованая линия маршрута)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)//  визуализация всей линии
                let distanse = String(format: "%.1f", route.distance/1000)//расстояние в м
                let timeInterval = route.expectedTravelTime // время в сек
                
                print("Расстояние до места \(distanse) км")
                print("Время в пути составит \(timeInterval) сек")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        // настройка запроса на построение маршрута от точки А к точке В
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate) // начало маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate) // конеч точка маршрута
        
        let request = MKDirections.Request()// маршрут от точки А к точке В, способ транспортировки
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        // тек координаты точки, находящиеся по центру экрана на карте
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    private func showAlert(title: String, message: String) {
        // выводим alert controller
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
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
        
        let center = getCenterLocation(for: mapView)// тек координаты по центру отобр области
        let geocoder = CLGeocoder()
        
        if incomeSegueIdenrifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation() // фокусировка на локации пол-ля
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
