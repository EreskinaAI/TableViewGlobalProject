//
//  PlaceModel.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 14.01.2021.
//

//import Foundation UIKit уже содержит в себе UIFoundation
import UIKit

struct Place {  // модель для хранения данных (отражение объекта), описывает все поля для доступности работы с объектом (внешний вид приложения)

	var name: String // не стоит опционал, тк поле-обязательно для заполнения
	var location: String?
	var type: String?
	var image: UIImage?
	var restaurantImage: String?

	static let restaurantNames = [ // вспомогательный массив в качестве св-ва struct для генерации тестовых записей
		"Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
		"Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка"
	]

	static func getListOfPlaces() -> [Place] { // чтобы вывести весь список заведений автоматизированно. Делаем св-во static, чтобы обращаться напрямую к struct, а не через экземпляр

		var arrayListOfPlaces = [Place]()

		for place in restaurantNames { // ищем соответствия из вспомагательного массива и подставляем(добавляем) в новый
			arrayListOfPlaces.append(Place(name: place,
										   location: "Уфа",
										   type: "Ресторан",
										   image: nil,
										   restaurantImage: place))
		}

		return arrayListOfPlaces



	}

}
