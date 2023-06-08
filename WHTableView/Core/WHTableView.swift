//
//  WHTableView.swift
//  WHTableView
//
//  Created by wanghong on 2023/6/6.
//

import UIKit

public class WHTableView: NSObject {
    public weak var scrollDelegate: WHTableViewScrollDelegate?
    public var tableView: UITableView!
    // table上添加的所有section
    public var sections: [WHTableViewSection] = []
    
    public init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
    }
    
    public func selectedItem<T: WHTableViewRow>() -> T? {
        if let item = selectedItems().first {
            return item as? T
        }
        return nil
    }

    public func selectedItems<T: WHTableViewRow>() -> [T] {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            var items = [T]()
            for idx in indexPaths {
                if let item = sections[idx.section].rows[idx.row] as? T {
                    items.append(item)
                }
            }
            return items
        }
        return []
    }

    public func selectItems(_ items: [WHTableViewRow], animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none) {
        for item in items {
            item.select(animated: animated, scrollPosition: scrollPosition)
        }
    }

    public func deselectItems(_ items: [WHTableViewRow], animated: Bool = true) {
        for item in items {
            item.deselect(animated: animated)
        }
    }
    /// 刷新高度
    public func updateHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    /// 注册cellId
    public func register(_ cell: any WHTableViewRowProtocol.Type, _ row: WHTableViewRow.Type, _ bundle: Bundle = Bundle.main) {
        wh_print("\(cell) 注册")
        if bundle.path(forResource: "\(cell)", ofType: "nib") != nil {
            tableView.register(UINib(nibName: "\(cell)", bundle: bundle), forCellReuseIdentifier: "\(row)")
        } else {
            tableView.register(cell, forCellReuseIdentifier: "\(row)")
        }
    }

    func sectionFrom(section: Int) -> WHTableViewSection {
        let section = sections.count > section ? sections[section] : nil
        assert(section != nil, "section超出范围")
        return section!
    }

    func getSectionAndItem(indexPath: (section: Int, row: Int)) -> (section: WHTableViewSection, row: WHTableViewRow) {
        let section = sectionFrom(section: indexPath.section)
        let item = section.rows.count > indexPath.row ? section.rows[indexPath.row] : nil
        assert(item != nil, "row超出范围")
        return (section, item!)
    }

    public func add(section: WHTableViewSection) {
        if !section.isKind(of: WHTableViewSection.self) {
            wh_print("section类型错误")
            return
        }
        section.wh_tableView = self
        sections.append(section)
    }

    public func remove(section: WHTableViewSection) {
        if !(section as AnyObject).isKind(of: WHTableViewSection.self) {
            wh_print("section类型错误")
            return
        }
        sections.remove(at: section.sectionIndex)
    }

    public func removeAllSections() {
        sections.removeAll()
    }

    public func reload() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension WHTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let obj = getSectionAndItem(indexPath: (section: indexPath.section, row: indexPath.row))
        if obj.row.isAllowSelect {
            return indexPath
        } else {
            return nil
        }
    }
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = getSectionAndItem(indexPath: (indexPath.section, indexPath.row))
        obj.row.selectionHandler?(obj.row)
    }
    public func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let obj = getSectionAndItem(indexPath: (section: indexPath.section, row: indexPath.row))
        return obj.row.editingStyle
    }
    public func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let obj = getSectionAndItem(indexPath: (section: indexPath.section, row: indexPath.row))

        if editingStyle == .delete {
            if let handler = obj.row.deletionHandler {
                handler(obj.row)
            }
        }
    }

    public func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        (cell as! (any WHTableViewRowProtocol)).rowDidDisappear()
    }

    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        (cell as! (any WHTableViewRowProtocol)).rowDidAppear()
    }

    public func tableView(_: UITableView, willDisplayHeaderView _: UIView, forSection section: Int) {
        let sectionModel = sectionFrom(section: section)
        sectionModel.headerWillDisplayHandler?(sectionModel)
    }

    public func tableView(_: UITableView, didEndDisplayingHeaderView _: UIView, forSection section: Int) {
        // 这里要做一个保护，因为这个方法在某个section被删除之后reload tableView, 会最后触发一次这个
        // section的endDisplaying方法，这时去根据section去获取section对象会获取不到。
        if sections.count > section {
            let sectionModel = sectionFrom(section: section)
            sectionModel.headerDidEndDisplayHandler?(sectionModel)
        }
    }

    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = sectionFrom(section: section)
        return sectionModel.headerView
    }

    public func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionModel = sectionFrom(section: section)
        return sectionModel.footerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionModel = sectionFrom(section: section)
        if sectionModel.headerView != nil || (sectionModel.headerHeight > 0 && sectionModel.headerHeight != CGFloat.leastNormalMagnitude) {
            return sectionModel.headerHeight
        }

        if let title = sectionModel.headerTitle {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 40, height: CGFloat.greatestFiniteMagnitude))
            label.text = title
            label.font = UIFont.preferredFont(forTextStyle: .footnote)
            label.sizeToFit()
            return label.frame.height + 20.0
        } else {
            return sectionModel.headerHeight
        }
    }

    public func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionModel = sectionFrom(section: section)
        return sectionModel.footerHeight
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        let item = section.rows[indexPath.row]
        if item.cellHeight == UITableView.automaticDimension, tableView.estimatedRowHeight == 0 {
            tableView.estimatedRowHeight = 44
            tableView.estimatedSectionFooterHeight = 44
            tableView.estimatedSectionHeaderHeight = 44
        }
        return item.cellHeight
    }
}

// MARK: - UITableViewDataSource

extension WHTableView: UITableViewDataSource {
    public func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionModel = sectionFrom(section: section)
        return sectionModel.headerTitle
    }

    public func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionModel = sectionFrom(section: section)
        return sectionModel.footerTitle
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = sectionFrom(section: section)
        return sectionModel.rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (_, item) = getSectionAndItem(indexPath: (indexPath.section, indexPath.row))

        var cell = tableView.dequeueReusableCell(withIdentifier: item.cellId) as? (any WHTableViewRowProtocol)
        if cell == nil {
            cell = (WHBaseRow(style: item.cellStyle, reuseIdentifier: item.cellId) as (any WHTableViewRowProtocol))
        }
        let unwrappedCell = cell!
        unwrappedCell.textLabel?.text = item.titleText
        unwrappedCell.textLabel?.textAlignment = item.textAlignment
        unwrappedCell.detailTextLabel?.text = item.detailLabelText
        unwrappedCell.detailTextLabel?.textAlignment = item.textAlignment
        unwrappedCell.accessoryView = item.accessoryView
        unwrappedCell.imageView?.image = item.image
        unwrappedCell.imageView?.highlightedImage = item.highlightedImage
        unwrappedCell.accessoryType = item.accessoryType
        unwrappedCell.selectionStyle = item.selectionStyle
        unwrappedCell._row = item
        unwrappedCell.rowWillAppear()
        return unwrappedCell
    }
}

