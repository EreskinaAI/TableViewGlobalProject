//
//  NewPlaceTableViewController.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 15.01.2021.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

	// удалили все методы, тк ячейка статическая, а не динамическая (без идентификатора, настроеная вручную)

	var currentPlace: Place? // тек заведение
var newPlace = Place() // инициализация значениями по умолчанию
	var imageIsChanged = false // для замены фонового изобр нашей картинкой(если пользователь не выбрал из галереи)

	@IBOutlet weak var placeImage: UIImageView! // outlet находится в самом классе, тк ячейки в этоим tableView не custom, а static
	@IBOutlet weak var placeName: UITextField!
	@IBOutlet weak var placeLocation: UITextField!
	@IBOutlet weak var placeType: UITextField!

	@IBOutlet weak var saveButton: UIBarButtonItem!


	override func viewDidLoad() {
        super.viewDidLoad()


		tableView.tableFooterView = UIView(frame: CGRect(x: 0,// строки табл, где нет контента будут без линий (как обычный view)
														 y: 0,
														 width: tableView.frame.size.width,
														 height: 1))


		saveButton.isEnabled = false //  кнопка save по умолчанию будет отключена

		placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
		// довавляем действие к аутлету через func (#selector) для логики отслеживания кнопки save и текст поля placeName

		setupEditScreen() 


    }

//	MARK: Table View Delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let cameraIcon = #imageLiteral(resourceName: "camera") // присваеваем icons рядом с actions в actionSheet (= image literal)
		let photoIcon =  #imageLiteral(resourceName: "photo")

//после выделения ячейки всплывает alertController, в противном случае - скрываем клавиатуру

		if indexPath.row == 0 {

			let actionSheet = UIAlertController(title: nil, // всплывет окно, чтобы загрузить изображение в ячейку
												message: nil,
												preferredStyle: .actionSheet)

			let camera = UIAlertAction(title: "Camera", style: .default) { (_) in // action "сделать фото с камеры"(возможность)
				self.chooceImagePicker(source: .camera) // метод из extension по работе с imagePickerController

			}
			camera.setValue(cameraIcon, forKey: "image") // устанавливаем icon camera
			camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") // размещаем icon слева от заголовка action camera

			let photo = UIAlertAction(title: "Photo", style: .default) { (_) in // action "выбрать фото из галлереи"
				self.chooceImagePicker(source: .photoLibrary)
			}
			photo.setValue(photoIcon, forKey: "image")
			photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			let cancel = UIAlertAction(title: "Cancel", style: .cancel) // action "закрыть всплывающее окно"

			actionSheet.addAction(camera)// добавляем на всплывающее окно(alertController) все actions
			actionSheet.addAction(photo)
			actionSheet.addAction(cancel)

			present(actionSheet, animated: true) // вызов непосредственно самого alercontroller

		} else {
			view.endEditing(true)
		}
	}
	func savePlace() { // передаем данные из текстовых полей в соответствии со св-вами struct (сохраняем как отредакттр ячейку, так и новый объект)

		var image: UIImage?

		if imageIsChanged == true {
			image = placeImage.image
		} else {
			image = #imageLiteral(resourceName: "imagePlaceholder")  // если пользователь не выбрал свою картинку, то ставим свое фоновое изображение
		}

		let imageData = image?.pngData() // конверт-я в тип Data (для realm)

		let newPlace = Place(name: placeName.text!,
							 location: placeLocation.text,
							 type: placeType.text!,
							 imageData: imageData)

		if currentPlace != nil {
			try! realm.write { // обновляем данные по редактир ячейке в базе данных
				currentPlace?.name = newPlace.name
				currentPlace?.location = newPlace.location
				currentPlace?.type = newPlace.type
				currentPlace?.imageData = newPlace.imageData
			}
		} else {
				StorageManager.saveObject(with: newPlace) // сохранение нового объекта в базе данных
		}


	}

	private func setupEditScreen() { // Редактируем уже заполненную ячейку с заведением

		if currentPlace != nil {

			setupNavigationBar() // метод доступен только при редактировании ячейки
			imageIsChanged = true // чтобы менялось фоновое изображение на выбранную картинку

			guard let data = currentPlace?.imageData, let image = UIImage(data: data)
			else {return} // конвертация в uiImage из data

			placeImage.image = image
			placeImage.contentMode = .scaleAspectFill // масштабирование картинки
			placeName.text = currentPlace?.name // присваеваем тек заведению значения из аутлетов
			placeLocation.text = currentPlace?.location
			placeType.text = currentPlace?.type
		}
	}

		private func setupNavigationBar() {// редактируем навигейшнбар внутри выделенной редактируемой ячейки

			if let topItem = navigationController?.navigationBar.topItem {// убираем заголовок у кнопки возврата
				topItem.backBarButtonItem = UIBarButtonItem(title: "",
															style: .plain,
															target: nil,
															action: nil)
			}

			navigationItem.leftBarButtonItem = nil // убрали кнопку cancel с панели
			title = currentPlace?.name // заголовок на панели это название заведения
			saveButton.isEnabled = true // доступность кнопки save
		}


	@IBAction func cancelAction(_ sender: Any) {
		dismiss(animated: true) // при нажатии cancel закрывается экран и возвращается на основной
	}
}

//	MARK: Textfield delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
	// скрываем клавиатуру по нажатию на ней кнопки Done

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	@objc private func textFieldChanged() { // метод из #selector
		if placeName.text?.isEmpty == false {
			saveButton.isEnabled = true
		} else {
			saveButton.isEnabled = false
		}
	}
}

// MARK: Work with image
// логика с каждым action  из alertController

extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate { // протокол для инфомирования о том, что происходит с выбранным фото {

	func chooceImagePicker(source: UIImagePickerController.SourceType) {
		// где source-источник для выбора изображения

		if UIImagePickerController.isSourceTypeAvailable(source) {
			// проверяем доступность imagePickerController

			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self // делегат по методу редактирования изображения передает ее классу
			imagePicker.allowsEditing = true // возможность пользователю редактировать выбранные изображения (масштабировать, обрезать и тд до сохранения)
			imagePicker.sourceType = source // тип источника для выбранного изображения = значение source
			present(imagePicker, animated: true) // вызов-отображение imagePickerController
		}

	}

	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		// метод из delegate, кот присваевает тип контента выбранному изображению

		placeImage.image = info[.editedImage] as? UIImage//  присваеваем в outlet отредактированное изображение
		placeImage.contentMode = .scaleAspectFill
		placeImage.clipsToBounds = true
		imageIsChanged = true // не меняем фоновую картинку, тк пользователь выбрал и отредактировал свою

		dismiss(animated: true) // закрываем метод после его реализации
	}

}
