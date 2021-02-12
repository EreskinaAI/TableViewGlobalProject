//
//  PlaceModel.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 14.01.2021.
//

//import Foundation UIKit уже содержит в себе UIFoundation

import RealmSwift

class Place: Object {  // модель для хранения данных (отражение объекта), описывает все поля для доступности работы с объектом (внешний вид приложения)

	@objc dynamic var name = "" // не стоит опционал, тк поле-обязательно для заполнения
	@objc dynamic var location: String?
	@objc dynamic var type: String?
	@objc dynamic var imageData: Data?
	@objc dynamic var date = Date() // св-во чисто для внутр испол-я (для сортировки по дате), не доступно пользователю
	@objc dynamic var rating = 0.0

	convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
// комплексный init в классе абсолютно для всех св-в

		self.init() // значения по умолчанию
		self.name = name //передаются значения из параметров
		self.location = location
		self.type = type
		self.imageData = imageData
		self.rating = rating
	}

}
