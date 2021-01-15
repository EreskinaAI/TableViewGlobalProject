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

			let actionSheet = UIAlertController(title: nil, // всплывет окно, чтобы загрузить изображение в ячейку
												message: nil,
												preferredStyle: .actionSheet)

			let camera = UIAlertAction(title: "Camera", style: .default) { (_) in // action "сделать фото с камеры"(возможность)
				self.chooceImagePicker(source: .camera) // метод из extension по работе с imagePickerController
			}
			let photo = UIAlertAction(title: "Photo", style: .default) { (_) in // action "выбрать фото из галлереи"
				self.chooceImagePicker(source: .photoLibrary)
			}
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) // action "закрыть всплывающее окно"

			actionSheet.addAction(camera)// добавляем на всплывающее окно(alertController) все actions
			actionSheet.addAction(photo)
			actionSheet.addAction(cancel)

			present(actionSheet, animated: true) // вызов непосредственно самого alercontroller

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

// MARK: Work with image
// логика с каждым action  из alertController

extension NewPlaceTableViewController {

	func chooceImagePicker(source: UIImagePickerController.SourceType) {
		// где source-источник для выбора изображения

		if UIImagePickerController.isSourceTypeAvailable(source) {
			// проверяем доступность imagePickerController

			let imagePicker = UIImagePickerController()
			imagePicker.allowsEditing = true // возможность пользователю редактировать выбранные изображения (масштабировать, обрезать и тд до сохранения)
			imagePicker.sourceType = source // тип источника для выбранного изображения = значение source
			present(imagePicker, animated: true) // вызов-отображение imagePickerController
		}

	}



}
