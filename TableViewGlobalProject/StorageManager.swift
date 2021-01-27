//
//  StorageManager.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 27.01.2021.
//

import RealmSwift // менеджер для работы с базой

 let realm = try! Realm() // точка входа в базу данных в виде переменной

class StorageManager {

	static func saveOblect(with place: Place) { // сохранение объекта в базе
		try! realm.write {
			realm.add(place)// добавили объект в базу данных
		}
	}
}

