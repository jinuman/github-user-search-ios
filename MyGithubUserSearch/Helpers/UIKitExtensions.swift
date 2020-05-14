//
//  UIKitExtensions.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 06/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIView {
    func addToSuperview(_ superview: UIView?) {
        superview?.addSubview(self)
    }
    
    func addSubviews(_ subviews: [UIView?]) {
        subviews.forEach {
            $0?.addToSuperview(self)
        }
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            $0.addToSuperview(self)
        }
    }
}

extension UIScrollView {
    
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        guard self.frame.size.height > 0
            && self.contentSize.height > 0 else { return false }
        
        return self.contentOffset.y
            + self.frame.size.height
            + edgeOffset
            > self.contentSize.height
    }
    
    func scrollToTop(animated: Bool = true) {
        let topInset = self.contentInset.top
        self.setContentOffset(
            CGPoint(x: 0, y: -topInset),
            animated: animated
        )
    }
    
}

extension UITableView {
    
    func setContentInsetWithScrollIndicatorsInset(contentInset: UIEdgeInsets) {
        self.contentInset = contentInset
        self.scrollIndicatorInsets = contentInset
    }
    
    public func registerNibName(_ name: String) {
        register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as? T ?? T()
    }
    
    /**
     다수의 UITableViewCell들을 동시에 register 할 수 있도록 도와준다.
     
     - Parameters:
        - cellTypes: 다수의 UITableViewCell.Type들로 이루어진 Array
     */
    func register(_ cellTypes: [UITableViewCell.Type]) {
        for cellType in cellTypes {
            self.register(cellType, forCellReuseIdentifier: "\(cellType.self)")
        }
    }
    
    // MARK: - Useful
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return self.numberOfSections > indexPath.section
            && self.numberOfRows(inSection: indexPath.section) > indexPath.row
    }
    
    func selectRowSafely(
        at indexPath: IndexPath,
        animated: Bool,
        scrollPosition: UITableView.ScrollPosition)
    {
        guard self.hasRowAtIndexPath(indexPath: indexPath) else { return }
        self.selectRow(
            at: indexPath,
            animated: animated,
            scrollPosition: scrollPosition
        )
    }
    
    func scrollToTopRowSafely(
        at scrollPosition: UITableView.ScrollPosition = .top,
        animated: Bool = true)
    {
        guard self.numberOfSections > 0,
            self.numberOfRows(inSection: 0) > 0 else {
                return
        }
        
        self.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: scrollPosition,
            animated: animated
        )
    }
    
    func scrollToRowSafely(
        at indexPath: IndexPath,
        at scrollPosition: UITableView.ScrollPosition,
        animated: Bool)
    {
        guard indexPath.section >= 0,
            self.numberOfSections > indexPath.section else {
                self.scrollToTop()
                return
        }
        
        guard indexPath.row >= 0,
            self.numberOfRows(inSection: indexPath.section) > indexPath.row else {
                self.scrollToTop()
                return
        }
        
        self.scrollToRow(
            at: indexPath,
            at: scrollPosition,
            animated: animated
        )
    }
    
    func clearSeparatorWhenEmpty() {
        self.tableFooterView = UIView()
    }
}

extension UICollectionView {
    
    func registerNibName(_ name: String) {
        register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(
        cellType: T.Type,
        for indexPath: IndexPath)
        -> T
    {
        return dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as? T ?? T()
    }
    
    /**
     다수의 UICollectionViewCell들을 동시에 register 할 수 있도록 도와준다.
     
     - Parameters:
     - cellTypes: 다수의 UICollectionViewCell.Type들로 이루어진 Array
     */
    func register(_ cellTypes: [UICollectionViewCell.Type]) {
        for cellType in cellTypes {
            self.register(cellType, forCellWithReuseIdentifier: "\(cellType.self)")
        }
    }
}
