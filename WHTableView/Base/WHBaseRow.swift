//
//  WHBaseRow.swift
//  WHTableView
//
//  Created by wanghong on 2023/6/6.
//

import UIKit

class WHBaseRow: UITableViewCell, WHTableViewRowProtocol {
    var row: WHRowProtocol!
    func rowWillAppear() {}
}
