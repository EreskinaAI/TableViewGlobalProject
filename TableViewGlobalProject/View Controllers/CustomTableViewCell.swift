//
//  CustomTableViewCell.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
	// outlets выносятся в отдельный класс, тк ячека tableView является custom

	@IBOutlet weak var imageOfPlace: UIImageView! {
		didSet {
			imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2 // округлить image view
			imageOfPlace.clipsToBounds = true  // округлить само изображение (обрезать по границам)

		}
	}
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var cosmosView: CosmosView! {
		didSet {
			cosmosView.settings.updateOnTouch = false //отключить возможность менять рейтинг на главном экране,а только внутри
		}
	}

	
}
