//
//  LeftSideViewController.swift
//  PWSideViewControlSwift
//
//  Created by PeterWang on 7/16/15.
//  Copyright (c) 2015 PeterWang. All rights reserved.
//

import UIKit

class LeftSideViewController: UIViewController {
  
  // MARK: - Variables
  private var tableArray = [String]()
  
  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Initializer
  convenience init() {
    self.init(nibName: "LeftSideViewController", bundle: NSBundle.mainBundle())
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    
    self.tableArray.append("A")
    self.tableArray.append("B")
    self.tableArray.append("C")
  }
}

// MARK: - UITableViewDataSource
extension LeftSideViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableArray.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell.self), forIndexPath: indexPath) 
    cell.textLabel?.text = self.tableArray[indexPath.row]
    cell.backgroundColor = .clearColor()
    return cell
  }
}

// MARK: - UITableViewDelegate
extension LeftSideViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}