//
//  WHTableViewSection.swift
//  WHTableView
//
//  Created by wanghong on 2023/6/6.
//

import UIKit
public typealias WHTableViewSectionBlock = (WHTableViewSection) -> Void
public class WHTableViewSection: NSObject {
    private weak var _tableView: WHTableView? // section持有所在的table
    var wh_tableView: WHTableView {
        get {
            guard let table = _tableView else {
                wh_print("table没有添加section")
                fatalError()
            }
            return table
        }
        set {
            _tableView = newValue
        }
    }
    /// section上的所有row
    var rows: [WHTableViewRow] = []
    // 高度默认44
    var headerHeight: CGFloat! = 44
    var footerHeight: CGFloat! = 44
    var headerView: UIView?
    var footerView: UIView?
    var headerTitle: String?
    var footerTitle: String?
    var headerWillDisplayHandler: WHTableViewSectionBlock?
    public func setHeaderWillDisplayHandler(_ block: WHTableViewSectionBlock?) {
        headerWillDisplayHandler = block
    }

    var headerDidEndDisplayHandler: WHTableViewSectionBlock?
    public func setHeaderDidEndDisplayHandler(_ block: WHTableViewSectionBlock?) {
        headerDidEndDisplayHandler = block
    }
    /// 当前section的下标
    var sectionIndex: Int {
        let index = wh_tableView.sections.firstIndex { (sec) -> Bool in
            sec == self
        }
        assert(index != nil, "section没有找到")
        return index!
    }
    
    override init() {
        super.init()
        headerHeight = CGFloat.leastNormalMagnitude
        footerHeight = CGFloat.leastNormalMagnitude
    }
    /// 添加cell
    func add(row: WHTableViewRow) {
        row.wh_section = self
        rows.append(row)
    }
    /// 移除cell
    func remove(row: WHTableViewRow) {
        rows.remove(at: row.indexPath.row)
    }
    /// 移除所有cell
    func removeAllRows() {
        rows.removeAll()
    }
    /// 替换cell
    func replaceRowsFrom(rowAry: [WHTableViewRow]) {
        removeAllRows()
        rows = rows + rowAry
    }
    /// 插入cell
    public func insert(_ row: WHTableViewRow!, afterRow: WHTableViewRow, animate: UITableView.RowAnimation = .automatic) {
        if !rows.contains(where: { $0 == afterRow }) {
            wh_print("不能插入row，因为afterItem不在section上")
            return
        }
        wh_tableView.tableView.beginUpdates()
        row.wh_section = self
        rows.insert(row, at: afterRow.indexPath.row + 1)
        wh_tableView.tableView.insertRows(at: [row.indexPath], with: animate)
        wh_tableView.tableView.endUpdates()
    }
    /// 插入多个cell
    public func insert(_ rowAry: [WHTableViewRow], afterRow: WHTableViewRow, animate: UITableView.RowAnimation = .automatic) {
        if !self.rows.contains(where: { $0 == afterRow }) {
            wh_print("不能插入rowAry，因为afterItem不在section上")
            return
        }

        wh_tableView.tableView.beginUpdates()
        let newFirstIndex = afterRow.indexPath.row + 1
        self.rows.insert(contentsOf: rowAry, at: newFirstIndex)
        var arrNewIndexPath = [IndexPath]()
        for i in 0 ..< rowAry.count {
            rows[i].wh_section = self
            arrNewIndexPath.append(IndexPath(item: newFirstIndex + i, section: afterRow.indexPath.section))
        }
        wh_tableView.tableView.insertRows(at: arrNewIndexPath, with: animate)
        wh_tableView.tableView.endUpdates()
    }
    /// 删除cell
    public func delete(_ rowsToDelete: [WHTableViewRow], animate: UITableView.RowAnimation = .automatic) {
        guard rowsToDelete.count > 0 else { return }
        wh_tableView.tableView.beginUpdates()
        var arrNewIndexPath = [IndexPath]()
        for i in rowsToDelete {
            arrNewIndexPath.append(i.indexPath)
        }
        for i in rowsToDelete {
            remove(row: i)
        }
        wh_tableView.tableView.deleteRows(at: arrNewIndexPath, with: animate)
        wh_tableView.tableView.endUpdates()
    }
    /// 刷新section
    public func reload(_ animation: UITableView.RowAnimation) {
        // If crash at here, section did not in manager！
        let index = wh_tableView.sections.firstIndex { (sec) -> Bool in
            sec == self
        }
        assert(index != nil, "section未添加到tableView上")
        wh_tableView.tableView.reloadSections(IndexSet(integer: index!), with: animation)
    }
}
