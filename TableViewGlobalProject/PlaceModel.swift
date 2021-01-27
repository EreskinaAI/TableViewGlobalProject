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


	 let restaurantNames = [ // вспомогательный массив в качестве св-ва struct для генерации тестовых записей
		"Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
		"Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка"
	]

 func savePlaces() { // одноразовый запуск и хранить в базе данных

		for place in restaurantNames { // ищем соответствия из вспомагательного массива и присваеваем значения св-вам класса

			let image = UIImage(named: place) // тек изобр заведения
			guard let imageData = image?.pngData() else {return}// конверт-я типа image в Data (в realm нет image)

			let newPlace = Place()

			newPlace.name = place
			newPlace.location = "Ufa"
			newPlace.type = "Restaurant"
			newPlace.imageData = imageData

			StorageManager.saveOblect(with: newPlace)



		}





	}

}
