//
//  MainViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {



	var arrayOfPlaces: Results<Place>! // текущее состояние хранилища в тек потоке/аналог массива(автообновл тип контейнера, кот возвращает запраш объекты)

	override func viewDidLoad() {
        super.viewDidLoad()

		arrayOfPlaces = realm.objects(Place.self) // отображение всех объектов из базы данных


    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1  // по умолчанию Table View возвращает 1 секцию
//    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return arrayOfPlaces.isEmpty ? 0 : arrayOfPlaces.count
    }



	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

		let place = arrayOfPlaces[indexPath.row] // объект по конкретной строке

		cell.nameLabel.text = place.name // обращаемся к св-ву из struct по конкретно вытащенному объекту
		cell.locationLabel.text = place.location
		cell.typeLabel.text = place.type
		cell.imageOfPlace.image = UIImage(data: place.imageData!)


		cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 // округлить image view
		cell.imageOfPlace.clipsToBounds = true  // округлить само изображение (обрезать по границам)

        return cell
    }

	
 // MARK: - Table View Delegate

	override func tableView(_ tableView: UITableView,// метод по редактированию строк(добавить/удалить) путем свайпа
							commit editingStyle: UITableViewCell.EditingStyle,
							forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let place = arrayOfPlaces[indexPath.row] // извлекаем объект из массива(списка заведений) для последующего удаления как из базы, так и из таблицы
			StorageManager.deleteObject(with: place)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
//
//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return 85   // увеличили высоту строк
//	}


    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//
//

	@IBAction func unwindSegue(segue: UIStoryboardSegue) {
		// при нажатии save передача данных из одного вьюконтроллера в другой

		guard let newPlaceVC = segue.source as? NewPlaceTableViewController else {return}
		newPlaceVC.saveNewPlace() // сохранили внесенные данные
		tableView.reloadData() // обновили данные таблицы
	}



}
