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
    
    let tableVC = LeftSideViewController()
    self.sideControl = PWSideViewControlSwift(embeddedViewController: self, leftViewController: tableVC)
    self.sideControl!.coverMode = .CoverNavigationBarView
    self.sideControl!.maskViewDidTapped = maskViewDidTapped
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .Plain, target: self, action: "leftTabBarButtonTapped")
  }

  // MARK: - Actions
  func leftTabBarButtonTapped() {
    if self.sideControl?.leftSideViewHidden ?? false {
      self.sideControl?.showLeftView(duration: 0.3, animated: true)
    } else {
      self.sideControl?.hideLeftView(duration: 0.3, animated: true)
    }
  }
  
  func maskViewDidTapped() {
    self.sideControl?.hideLeftView(duration: 0.3, animated: true)
  }
}

