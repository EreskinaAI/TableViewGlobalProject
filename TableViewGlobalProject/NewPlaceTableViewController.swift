//
//  NewPlaceTableViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 15.01.2021.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

	// удалили все методы, тк ячейка статическаяБ а не динамическая (без идентификатора, настроеная вручную)

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.tableFooterView = UIView() // строки табл, где нет контента будут без линий (как обычный view)

    }

//	MARK: Table View Delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//после выделения ячейки (если это не ячейка с вызовом "меню", скрываем клавиатуру

		if indexPath.row == 0 {

		} else {
			view.endEditing(true)
		}
	}
}

//	MARK: Textfield delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
	// скрываем клавиатуру по нажатию на ней кнопки Done

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
