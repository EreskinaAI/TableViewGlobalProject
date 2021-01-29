//
//  StorageManager.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 27.01.2021.
//

import RealmSwift // менеджер для работы с базой

 let realm = try! Realm() // точка входа в базу данных в виде переменной

class StorageManager {

	static func saveObject(with place: Place) { // логика по сохранению объекта в базе
		try! realm.write {
			realm.add(place)// добавили объект в базу данных
		}
	}
	static func deleteObject(with place: Place) {// логика по удалению объекта из базы
		try! realm.write {
			realm.delete(place)
		}
	}
}

