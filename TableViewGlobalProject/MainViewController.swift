//
//  MainViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var reversedSortingButton: UIBarButtonItem!

	var arrayOfPlaces: Results<Place>! // текущее состояние хранилища в тек потоке/аналог массива(автообновл тип контейнера, кот возвращает запраш объекты)
	var ascendingSorting = true // св-во(сортировка по умолчанию массива по возрастанию)

	override func viewDidLoad() {
        super.viewDidLoad()

		arrayOfPlaces = realm.objects(Place.self) // отображение всех объектов из базы данных


    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1  // по умолчанию Table View возвращает 1 секцию
//    }


     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return arrayOfPlaces.isEmpty ? 0 : arrayOfPlaces.count
    }



 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

	 func tableView(_ tableView: UITableView,// метод по редактированию строк(добавить/удалить) путем свайпа
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


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// переход на экран, нажимая по ячейке с заведением

		if segue.identifier == "showDetail" {
			guard let indexPath = tableView.indexPathForSelectedRow else {return} // достаем индекс по выделенной ячейке
			let place = arrayOfPlaces[indexPath.row] // достаем элемент уэе по этому индексу из массива
			let newPlaceVC = segue.destination as! NewPlaceTableViewController // достучались до экрана перехода
			newPlaceVC.currentPlace = place// передали объект из выделенной существ ячейки с заведением на новый экран

		}

    }



	@IBAction func unwindSegue(segue: UIStoryboardSegue) {
		// при нажатии save передача данных из одного вьюконтроллера в другой

		guard let newPlaceVC = segue.source as? NewPlaceTableViewController else {return}
		newPlaceVC.savePlace() // сохранили внесенные данные
		tableView.reloadData() // обновили данные таблицы
	}

	@IBAction func sortSelection(_ sender: UISegmentedControl) {
		// сортировка в segmentedControl по выбранному индексу

		sorting()

		tableView.reloadData()
	}

	@IBAction func reversedSorting(_ sender: Any) {
		// сортировка на навигейшнконтроллере кнопкой стрелки вверх-вниз(реверсия)

		ascendingSorting.toggle() // встроенный метод для смены значений на противоположное у типа Bool
		if ascendingSorting == true {
			reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
		} else {
			reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
		}
		sorting()
	}

	private func sorting() {// комплексная сортировка в зависимости от значения (2 параметра участвуют)

		if segmentedControl.selectedSegmentIndex == 0 {
			arrayOfPlaces = arrayOfPlaces.sorted(byKeyPath: "date", ascending: ascendingSorting)
		} else {
			arrayOfPlaces = arrayOfPlaces.sorted(byKeyPath: "name", ascending: ascendingSorting)
		}

		tableView.reloadData()
	}
}
