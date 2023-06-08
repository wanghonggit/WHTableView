//
//  WHExpandMoreRow.swift
//  Pods-WHTableView_Example
//
//  Created by wanghong on 2023/6/6.
//

import UIKit

open class WHExpandMoreRow: WHTableViewRow {
    /// 当前节点层级
    public var level: Int = 0
    /// 是否展开
    public var isExpand = false
    /// 所有row节点
    public var rowSubLevel: [WHExpandMoreRow] = []
    /// 展开或收起回调
    public var expandBlock: ((WHExpandMoreRow) -> Void)?
    /// 父节点
    public var superLevelRow: WHExpandMoreRow?
    /// 收起时是否保持下级的树形结构
    public var isKeepStructure = true
    /// 是否自动收起
    public var isAutoClose = false
    
    public override init() {
        super.init()
        selectionStyle = .none
        
        setSelectionHandler { [weak self] (callBackItem: WHExpandMoreRow) in
            guard let self = self else {return}
            if let superLevel = self.superLevelRow, superLevel.isAutoClose {
                // 处理已经展开的row
                let arrRows = superLevel.getAllBelowRows().filter {
                    $0.level == self.level && $0 != self && $0.isExpand
                }
                for row in arrRows {
                    row.toggleExpand()
                }
            }
            callBackItem.toggleExpand()
        }
    }
    
    /// 添加子row节点
    public func addSub(row: WHExpandMoreRow, section: WHTableViewSection) {
        rowSubLevel.append(row)
        row.superLevelRow = self
        row.level = level + 1
        if WHExpandMoreRow.checkIfFoldedBySupperLevel(self), isExpand {
            wh_section.add(row: row)
        }
    }
    
    /// 处理展开事件，返回值是当前cell的状态（展开或者收起）
    @discardableResult open func toggleExpand() -> Bool {
        var arrRows: [WHExpandMoreRow]
        if isExpand {
            // 点击之前是打开的，直接通过递归获取item
            arrRows = getAllBelowRows()
            isExpand = !isExpand
        } else {
            // 点击之前是关闭的，需要先改变isExpand属性（不这么做会导致这一个level下一级的cell不显示）
            isExpand = !isExpand
            arrRows = getAllBelowRows()
            if !isKeepStructure {
                var tempRows = [WHExpandMoreRow]()
                for row in arrRows {
                    row.isExpand = false
                    if row.level == level + 1 {
                        tempRows.append(row)
                    }
                }
                arrRows = tempRows
            }
        }
        if expandBlock != nil {
            expandBlock?(self)
        }
        if isExpand {
            wh_section.insert(arrRows, afterRow: self, animate: .fade)
        } else {
            wh_section.delete(arrRows, animate: .fade)
        }
        wh_print(isExpand ? "展开" : "收起")
        return isExpand
    }
    
    /// 获取当前row下面所有的row
    public func getAllBelowRows() -> [WHExpandMoreRow] {
        var arrRows = [WHExpandMoreRow]()
        WHExpandMoreRow.recursionForItem(self, outRows: &arrRows)
        return arrRows
    }
    
    /// 递归获取一个row下面所有显示的row
    public class func recursionForItem(_ row: WHExpandMoreRow, outRows: inout [WHExpandMoreRow]) {
        for subRow in row.rowSubLevel {
            wh_print("row的层级：\(subRow.level)")
            if row.isExpand == true {
                outRows.append(subRow)
                if row.rowSubLevel.count != 0 {
                    recursionForItem(subRow, outRows: &outRows)
                }
            }
        }
    }
    
    /// 递归判断一个row是否在某个父节点被折叠
    public class func checkIfFoldedBySupperLevel(_ row: WHExpandMoreRow) -> Bool {
        guard let superRow = row.superLevelRow else {
            return row.isExpand
        }

        if superRow.isExpand {
            return checkIfFoldedBySupperLevel(superRow)
        } else {
            return false
        }
    }
}
