//
//  MainViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	private let searchController = UISearchController(searchResultsController: nil) // результаты поиска = на том же экране где контент
	private var arrayOfPlaces: Results<Place>! // текущее состояние хранилища в тек потоке/аналог массива(автообновл тип контейнера, кот возвращает запраш объекты)
	private var filteredPlaces: Results<Place>! // массив уже с отфильтр местами
	private var ascendingSorting = true // св-во(сортировка по умолчанию массива по возрастанию)
	private var searchBarIsEmpty: Bool { // возвращает true если строка поиска пустая
		guard let text = searchController.searchBar.text else {return false}
		return text.isEmpty
	}
	private var isFiltering: Bool {// св-во для отслеж-я активации поиск запроса
		return searchController.isActive && !searchBarIsEmpty
	}


	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var reversedSortingButton: UIBarButtonItem!



	override func viewDidLoad() {
        super.viewDidLoad()

		arrayOfPlaces = realm.objects(Place.self) // отображение всех объектов из базы данных

//		MARK: setup the search controller
		searchController.searchResultsUpdater = self  // получатель обновления поиска это сам класс
		searchController.obscuresBackgroundDuringPresentation = false// взаимод-е с контроллером отображения поиска как с основным
		searchController.searchBar.placeholder = "Search"// название строки поиска
		navigationItem.searchController = searchController // строку поиска встраиваем в навигейшн бар
		definesPresentationContext = true// отспускаем строку поиска при переходе на др экран

    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1  // по умолчанию Table View возвращает 1 секцию
//    }


     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if isFiltering == true {
			return filteredPlaces.count // при активной строке поиска количество строк берем из отфильтр массива
		}

		return arrayOfPlaces.count
    }



 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell


	let place = isFiltering ? filteredPlaces[indexPath.row] : arrayOfPlaces[indexPath.row]
	// достаем конкретный объект из опред массива(либо из отфильтр, либо из обычного)

		cell.nameLabel.text = place.name // обращаемся к св-ву из struct по конкретно вытащенному объекту
		cell.locationLabel.text = place.location
		cell.typeLabel.text = place.type
		cell.imageOfPlace.image = UIImage(data: place.imageData!)
	cell.cosmosView.rating = place.rating // отобр-е правильного кол-ва звезд(рейтинг) на глав экране

        return cell
    }

	
 // MARK: - Table View Delegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)// отмена выделения после закрытия окна редактирования
	}

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

			let place = isFiltering ?  filteredPlaces[indexPath.row] : arrayOfPlaces[indexPath.row]
				// попадаем на экран с деталями в зависимости от массива(отфильтр или нет)


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
extension MainViewController: UISearchResultsUpdating {
	// обновляем рез-ты поиска в соответствии с введенным значением в саму строку поиска


	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(with: searchController.searchBar.text!) // вызов приват метода по вводимому в строку поиска
	}
	private func filterContentForSearchText(with searchText: String) {
		// фильтрация контента в соответствии с поисковым запросом

		filteredPlaces = arrayOfPlaces.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)

// фильтруем в realm по названию и локации (не важно заглавная буква или строчная [c] и подставляем текст из строки поиска)
		// %@ - подстановка элемента место значения, predicate statement в "", после запятой подстановка значения по порядку

		tableView.reloadData()
	}
}

