//
//  RatingControl.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 09.02.2021.
//

import UIKit

@IBDesignable class RatingControl: UIStackView { // @IBDesignable - отображение контента в storyboard

	// MARK: Properties
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

	var rating = 0


	// MARK: Initialization (frame - для работы через код, requared coder - "обязательный" для работы черед storyboard)

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
		print("Button pressed 👍")
	}

	// MARK: Private methods

	private func setupButtons() { // добавили кнопку 5 раз с настройками

		for button in ratingButtons { //очистка старых кнопок перед добавлением новых
			removeArrangedSubview(button)
			button.removeFromSuperview()
		}
		ratingButtons.removeAll()

		for _ in 0..<starCount {

			// MARK: Create the button
			let button = UIButton()
			button.backgroundColor = .red
			
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

	}

}
