//
//  RatingControl.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 09.02.2021.
//

import UIKit

@IBDesignable class RatingControl: UIStackView { // @IBDesignable - отображение контента в storyboard

	// MARK: Properties

	var rating = 0 {
		didSet {
			updateButtonSelectionState()
		}
	}

	private var ratingButtons = [UIButton]() // массив из кнопок

	@IBInspectable var starSize: CGSize = CGSize(width: 44, height: 44) {// @IBInspectable - отображение св-в из кода в storyboard

		didSet {// наблюдатели за изменениями св-в
			setupButtons()
		}
	}

	@IBInspectable var starCount: Int = 5 {
		didSet {
			setupButtons()
		}
	}



	// MARK: Initialization
	//(frame - для работы через код, requared coder - "обязательный" для работы черед storyboard)

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupButtons()
	}

	required init(coder: NSCoder) {
		super.init(coder: coder)
		setupButtons()
	}

	// MARK: Button action
	@objc func ratingButtonTapped(with button: UIButton) {

		guard let index = ratingButtons.firstIndex(of: button) else {return}// индекс кнопки, кот. касается пользователь

		// MARK: Calculate the rating of the selected button
		let selectedRating = index + 1

		if selectedRating == rating { // обнуление если рейтинг старый = рейтингу новому выбранному
			rating = 0
		} else {
			rating = selectedRating
		}
	}




	// MARK: Private methods

	private func setupButtons() { // добавили кнопку 5 раз с настройками

		for button in ratingButtons { //очистка старых кнопок перед добавлением новых
			removeArrangedSubview(button)
			button.removeFromSuperview()
		}
		ratingButtons.removeAll()

		// MARK: Load button image
		let bundle = Bundle(for: type(of: self)) // путь к изобр из assets

		let filledStar = UIImage(named: "filledStar",
								 in: bundle,
								 compatibleWith: self.traitCollection)

		let emptyStar = UIImage(named: "emptyStar",
							   in: bundle,
							   compatibleWith: self.traitCollection)

		let highlightedStar = UIImage(named: "highlightedStar",
									  in: bundle,
									  compatibleWith: self.traitCollection)

		for _ in 0..<starCount {

			// MARK: Create the button
			let button = UIButton()

//			// MARK: Setup button image
			button.setImage(emptyStar, for: .normal)
			button.setImage(filledStar, for: .selected)
			button.setImage(highlightedStar, for: .highlighted)
			button.setImage(highlightedStar, for: [.highlighted, .selected])

			
			// MARK: Add constraints
			button.translatesAutoresizingMaskIntoConstraints = false // отключать авторазмер для создания своих констрейнтов
			button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
			button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true

			// MARK: Setup the button action
			button.addTarget(self, action: #selector(ratingButtonTapped(with:)), for: .touchUpInside)

			// MARK: Add the button into the stackview
			addArrangedSubview(button)

			// MARK: Add the new button into the rating button array
			ratingButtons.append(button)

		}
updateButtonSelectionState()
	}

	func updateButtonSelectionState() {// обновление внеш вида кнопок в соответствии с рейтингом

		for (index, button) in ratingButtons.enumerated() {
			button.isSelected = index < rating
		}

	}

}
