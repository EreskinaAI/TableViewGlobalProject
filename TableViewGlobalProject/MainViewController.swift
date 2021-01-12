//
//  MainViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit

class MainViewController: UITableViewController {

	let restaurantNames = [
		"Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
		"Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life", "Шок", "Бочка"
	]

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1  // по умолчанию Table View возвращает 1 секцию
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return restaurantNames.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

		cell.nameLabel.text = restaurantNames[indexPath.row]
		cell.imageOfPlace.image = UIImage(named: restaurantNames[indexPath.row]) // индекс названия в массиве соответствует индексу (названию) картинки
		cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 // округлить image view
		cell.imageOfPlace.clipsToBounds = true  // округлить само изображение (обрезать по границам)

        return cell
    }

 // MARK: - Table View Delegate

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 85   // увеличили высоту строк
	}


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
