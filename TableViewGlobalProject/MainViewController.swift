//
//  MainViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit

class MainViewController: UITableViewController {



//	var arrayOfPlaces = Place.getListOfPlaces() // метод из struct, который вернет новый заполненный массив с полным списком заведений

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1  // по умолчанию Table View возвращает 1 секцию
//    }

	/*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return arrayOfPlaces.count
    }
*/

/*
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

		let place = arrayOfPlaces[indexPath.row] // объект по конкретной строке

		cell.nameLabel.text = place.name // обращаемся к св-ву из struct по конкретно вытащенному объекту
		cell.locationLabel.text = place.location
		cell.typeLabel.text = place.type

		if place.image == nil {  // присваеваем изображение либо из названия либо свое выбираем
			cell.imageOfPlace.image = UIImage(named: place.restaurantImage!)
		} else {
			cell.imageOfPlace.image = place.image
		}

		cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 // округлить image view
		cell.imageOfPlace.clipsToBounds = true  // округлить само изображение (обрезать по границам)

        return cell
    }
*/
	
 // MARK: - Table View Delegate
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
//		arrayOfPlaces.append(newPlaceVC.newPlace!) //  добавили в массив новый заполненный объект
		tableView.reloadData() // обновили данные таблицы
	}



}
