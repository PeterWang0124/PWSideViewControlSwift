//
//  ViewController.swift
//  PWSideViewControlSwift
//
//  Created by PeterWang on 7/16/15.
//  Copyright (c) 2015 PeterWang. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {

  // MARK: - Private variables
  private var sideControl: PWSideViewControlSwift?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tableVC = UITableViewController(style: .Plain)
    tableVC.view.backgroundColor = .greenColor()
    self.sideControl = PWSideViewControlSwift(embeddedViewController: self, leftViewController: tableVC)
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .Plain, target: self, action: "leftTabBarButtonTapped")
  }

  // MARK: - Actions
  func leftTabBarButtonTapped() {
    if self.sideControl?.leftSideViewHidden ?? false {
      self.sideControl?.showLeftView()
    } else {
      self.sideControl?.hideLeftView()
    }
  }
}

