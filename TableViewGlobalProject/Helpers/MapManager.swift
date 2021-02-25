//
//  MapManager.swift
//  TableViewGlobalProject
//
//  Created by Анна Ереськина on 25.02.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager() // экз. класса по настройке и упр-ю службами геолокации
    private var placeCoordinate:CLLocationCoordinate2D? // координаты заведения
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = [] // массив для хранения маршрутов (предыдущих и новых)
    
    // MARK: Маркер заведения
    
     func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            //Привязываем annotation к конкрет.точке на карте в связи с локацией метки(булавки)
            
            guard let placemarkLocation = placemark?.location else { return }
            // местоположение булавки
            
            annotation.coordinate = placemarkLocation.coordinate
            // привязываем annotation к местоположению булавки
            
            self.placeCoordinate = placemarkLocation.coordinate
            // координаты заведения-это и есть булавка
            
            mapView.showAnnotations([annotation], animated: true)
            // показываем все annotations на карте
            
            mapView.selectAnnotation(annotation, animated: true)
            // отметка на карте большая подсвечивается
        }
    }
    
    // MARK: Проверка доступности сервисов геолокации(a если нет - вызов alert controller)
    
     func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // высокоточное опр-е местоположения пользователя
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // отложить выполнение задачи на 1 сек после viewDidLoad
                self.showAlert(title: "Location services are disabled",
                               message: "To enable it go: Settings -> Privacy -> Location services and turn on")
            }
        }
    }
    
    // MARK:  Проверка авторизации приложения для испол-я сервисов геолокации
    
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        
        switch CLLocationManager().authorizationStatus {// возвращает 5 основных состояний авторизации для геолокации
        case .authorizedWhenInUse: // в момент исп-я
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    // MARK: Фокус карты на тек метоположении пол-ля
    
    func showUserLocation(mapView: MKMapView) {
       
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            //  прямоугольник с радиусом в районе с заданными долготой и шириной
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    //    MARK: Строим маршрут от местоположения пол-ля до заведения
        
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
            
            guard let location = locationManager.location?.coordinate else { // координаты пол-ля
                showAlert(title: "Error", message: "Current location is not found")
                return
            }
            
            locationManager.startUpdatingLocation()// постоянное отслеживание тек локации пол-ля
            previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
            
            guard let request = createDirectionsRequest(from: location) else {
                // запрос на прокладку маршрута от положения пол-ля
                
                showAlert(title: "Error", message: "Destination is not found")
                return
            }
            let directions = MKDirections(request: request) //создаем маршрут на основании сведений из запроса
        
            resetMapView(withNew: directions, mapView: mapView) // избавляемся от тек маршрутом перед созданием нового
            
            directions.calculate { (response, error) in  //расчет маршрута
              
                if let error = error {
                    print(error)
                    return
                }
                guard let response = response else {
                    self.showAlert(title: "Error", message: "Directions is not available")
                    return
                }
                for route in response.routes { // перебиранем все маршруты (детали)
                    mapView.addOverlay(route.polyline)//  накладываем геометрию(прорисованая линия маршрута)
                    mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)//  визуализация всей линии
                    let distanse = String(format: "%.1f", route.distance/1000)//расстояние в м
                    let timeInterval = route.expectedTravelTime // время в сек
                    
                    print("Расстояние до места \(distanse) км")
                    print("Время в пути составит \(timeInterval) сек")
                }
            }
        }
       
    // MARK: Настройка запроса для расчета маршрута
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
       
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
    
    // MARK: Меняем отобр зону области карты в соответствии с перемещением пол-ля
    
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)// тек координаты центра отображ области
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // MARK: Сброс всех ранее построенных маршрутов перед постоением нового
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)// удаляем наложение тек маршрута с карты
        directionsArray.append(directions)// добавляем тек маршруты в массив
        let _ = directionsArray.map { $0.cancel() } //перебираем все элементы в массиве и отменяем маршруты
        directionsArray.removeAll()
    }
    
    // MARK: Определение центра отображаемой области карты
    
   func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func showAlert(title: String, message: String) {
        // выводим alert controller
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)// окно по границе экрана
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1//позиция данного окна относительно др окон (поверх всех)
        alertWindow.makeKeyAndVisible()//окно становится ключевым и видимым
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
}

