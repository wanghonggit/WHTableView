//
//  WHTableViewRow.swift
//  WHTableView
//
//  Created by wanghong on 2023/6/6.
//

import UIKit
public typealias WHTableViewRowBlock = (WHTableViewRow) -> Void
public class WHTableViewRow: NSObject {
    // 从section中获取row所在的table
    var wh_tableView: WHTableView {
        return wh_section.wh_tableView
    }
    private weak var _section: WHTableViewSection? // row持有所在的section
    var wh_section: WHTableViewSection {
        get {
            guard let sec = _section else { fatalError() }
            return sec
        }
        set {
            _section = newValue
        }
    }
    var cellId: String! // cellIdentifier
    var cellHeight: CGFloat! // cell高度,在cell中设置
    var titleText: String = "" // cellTitleText
    var detailLabelText: String = "" // cellDetailText
    var textAlignment: NSTextAlignment = .left
    var image: UIImage?
    var highlightedImage: UIImage?
    var cellStyle: UITableViewCell.CellStyle = .default
    var accessoryType: UITableViewCell.AccessoryType = .none
    var selectionStyle: UITableViewCell.SelectionStyle = .default
    var editingStyle: UITableViewCell.EditingStyle = .none
    var accessoryView: UIView?
    /// 是否选中cell
    var isSelected: Bool {
        return row.isSelected
    }
    var isAllowSelect: Bool = true
    /// 当前cell的位置
    var indexPath: IndexPath {
        let rowIndex = wh_section.rows.firstIndex { (row) -> Bool in
            row == self
        }
        let sectionIndex = wh_tableView.sections.firstIndex { (section) -> Bool in
            section == self.wh_section
        }
        assert(rowIndex != nil && sectionIndex != nil, "获取对应元素下标失败")
        return IndexPath(row: rowIndex!, section: sectionIndex!)
    }
    /// 当前cell
    var row: UITableViewCell {
        guard let row = wh_tableView.tableView.cellForRow(at: indexPath) else {
            wh_print("获取tableViewRow失败，需要先添加tableViewRow到tableView并且reload只有在能获取，且row需要在屏幕范围内显示")
            fatalError()
        }
        return row
    }
    
    /// cell点击事件的回调
    public var selectionHandler: WHTableViewRowBlock?
    public func setSelectionHandler<T: WHTableViewRow>(_ handler: ((_ callBackItem: T) -> Void)?) {
        selectionHandler = { item in
            handler?(item as! T)
        }
    }

    public var deletionHandler: WHTableViewRowBlock?
    public func setDeletionHandler<T: WHTableViewRow>(_ handler: ((_ callBackItem: T) -> Void)?) {
        deletionHandler = { item in
            handler?(item as! T)
        }
    }
    
    override init() {
        super.init()
        // 默认cellId为cell类名
        cellId = "\(type(of: self))"
        // 默认cell高度
        cellHeight = 44
    }
    /// 刷新row
    func reload(_ animation: UITableView.RowAnimation) {
        wh_print("刷新cell---\(indexPath)")
        wh_tableView.tableView.beginUpdates()
        wh_tableView.tableView.reloadRows(at: [indexPath], with: animation)
        wh_tableView.tableView.endUpdates()
    }
    /// 选择row
    func select(animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none) {
        if isAllowSelect {
            wh_tableView.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }
    func deselect(animated: Bool = true) {
        wh_tableView.tableView.deselectRow(at: indexPath, animated: animated)
    }
    /// 删除row
    func delete(_ animation: UITableView.RowAnimation = .automatic) {
        if _section == nil {
            wh_print("删除失败，section未添加")
            return
        }
        if !_section!.rows.contains(where: { $0 == self}) {
            wh_print("删除失败，当前row没有添加到section")
            return
        }
        let indexPath = indexPath
        _section?.rows.remove(at: indexPath.row)
        wh_tableView.tableView.deleteRows(at: [indexPath], with: animation)
    }
    /// 计算row的高度
    func autoHeight(_ table: WHTableView) {
        guard let row = table.tableView.dequeueReusableCell(withIdentifier: cellId) as? WHTableViewRowProtocol else {
            wh_print("cell未注册cellIdentifier")
            return
        }
        row.row = self
        row.rowWillAppear()
        cellHeight = row.systemLayoutSizeFitting(CGSize(width: table.tableView.frame.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }
}
