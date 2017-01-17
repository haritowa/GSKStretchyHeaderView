//
//  SeveralScrollViewsViewController.swift
//  Example
//
//  Created by haritowa on 1/17/17.
//  Copyright © 2017 Jose Alcalá Correa. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView

fileprivate struct Constants {
    // Table View
    struct TableView {
        static let count = 2
        
        static let cellBackgorundColors: [UIColor] = [
            .green,
            .red
        ]
    }
    
    // Header
    struct Header {
        static let minimumHeight: CGFloat = 22
        static let maximumHeight: CGFloat = 100
    }
}

class ButtonHeaderView: GSKStretchyHeaderView {
    let maxFontSize: CGFloat = 40
    let minFontSize: CGFloat = 20
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 20, width: self.contentView.width, height: self.contentView.height - 20))
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.setTitle("Toggle tableview", for: UIControlState(rawValue: 0))
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.maximumContentHeight = self.width
        self.minimumContentHeight = 64
        
        self.contentView.addSubview(self.button)
        self.backgroundColor = UIColor.orange
    }
}

class SeveralScrollViewsViewController: UIViewController, UITableViewDataSource, GSKStretchyHeaderObservationTargetProvider {
    private let tableViews: [UITableView]
    private var selectedTableViewIndex: Int = -1
    
    private let headerView: ButtonHeaderView
    
    // MARK: - Init
    init() {
        tableViews = (0..<Constants.TableView.count).map { _ in UITableView() }
        
        let screenWidth = UIScreen.main.bounds.width
        
        let headerViewOrigin = CGPoint(x: 0, y: 64)
        headerView = ButtonHeaderView(frame: CGRect(origin: headerViewOrigin,
                                                           size: CGSize(width: screenWidth, height: screenWidth)))
        
        headerView.manageScrollViewOffset = true
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupConstraints()
        setTableViewSelected(at: 0)
    }
    
    private func setupViews() {
        tableViews.forEach { tableView in
            view.addSubview(tableView)
            tableView.dataSource = self
            tableView.isHidden = true
        }
        
        view.addSubview(headerView)
        headerView.observationTargetProvider = self
        
        headerView.button.addTarget(self,
                                    action: #selector(SeveralScrollViewsViewController.toggleButtonPressed),
                                    for: .primaryActionTriggered)
    }
    
    @objc func toggleButtonPressed() {
        if selectedTableViewIndex == 0 {
            setTableViewSelected(at: 1)
        } else {
            setTableViewSelected(at: 0)
        }
    }
    
    private func setupConstraints() {
        tableViews.forEach(bindToRootView)
    }
    
    private func bindToRootView(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        subview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Header delegate
    private func getTableView(for index: Int) -> UITableView? {
        guard index >= 0, index < tableViews.count else { return nil }
        return tableViews[index]
    }
    
    private func setTableViewSelected(at index: Int) {
        guard index != selectedTableViewIndex else { return }
        
        let currentTableView = getTableView(for: selectedTableViewIndex)
        let nextTableView = getTableView(for: index)
        
        selectedTableViewIndex = index
        
        nextTableView?.alpha = 0
        nextTableView?.isHidden = false
        
        if let tableView = nextTableView {
            view.insertSubview(tableView, belowSubview: headerView)
        }
        
        UIView.animate(withDuration: 0.3, animations: { 
            nextTableView?.alpha = 1
            currentTableView?.alpha = 0
        }) { _ in
            currentTableView?.isHidden = true
        }
        
        headerView.resetObservationTarget()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        
        if let index = tableViews.index(of: tableView) {
            let colorIndex = index % Constants.TableView.cellBackgorundColors.count
            cell.backgroundColor = Constants.TableView.cellBackgorundColors[colorIndex]
        }
        
        return cell
    }
    
    // MARK: - GSKStretchyHeaderObservationTargetProvider
    func shouldReplaceTarget(with scrollView: UIScrollView?) -> Bool {
        return false
    }
    
    func getTargetForHeader(_ header: GSKStretchyHeaderView) -> UIScrollView? {
        return tableViews[selectedTableViewIndex]
    }
}
