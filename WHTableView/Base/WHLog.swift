//
//  WHLog.swift
//  WHTableView
//
//  Created by wanghong on 2023/6/6.
//

import UIKit

public func wh_print<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = dateFormatter.string(from: Date())
    #if DEBUG
    print("WHTableView:\(date)-->\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
