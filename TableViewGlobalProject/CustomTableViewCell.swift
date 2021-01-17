//
//  CustomTableViewCell.swift
//  TableViewGlobalProject
//
//  Created by 17795838 on 12.01.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
	// outlets выносятся в отдельный класс, тк ячека tableView является custom

	@IBOutlet weak var imageOfPlace: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!
	
	
}
