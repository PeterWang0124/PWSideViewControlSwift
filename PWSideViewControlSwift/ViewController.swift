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
    
    let leftView = UIView()
    leftView.backgroundColor = .redColor()
    let leftItem = PWSideViewItem(embedView: leftView)
    leftItem.size.widthValue = 0.9
    
    let rightView = UIView()
    rightView.backgroundColor = .greenColor()
    let rightItem = PWSideViewItem(embedView: rightView)
    rightItem.size.widthValue = 0.9
    rightItem.hiddenPosition.horizontal = .Right
    rightItem.shownPosition.horizontal = .Right
    
    self.sideControl = PWSideViewControlSwift(embeddedView: self.view)
    self.sideControl?.addSideViewItem(leftItem)
    self.sideControl?.addSideViewItem(rightItem)
    self.sideControl?.coverMode = .CoverNavigationBarView
    self.sideControl?.maskViewDidTapped = maskViewDidTapped
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .Plain, target: self, action: #selector(ViewController.leftTabBarButtonTapped))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Right", style: .Plain, target: self, action: #selector(ViewController.rightTabBarButtonTapped))
  }

  // MARK: - Actions
  func leftTabBarButtonTapped() {
    let hidden = self.sideControl?.isSideViewItemHiddenAtIndex(0) ?? true
    self.sideControl?.sideViewItemAtIndex(0, hidden: !hidden, withDuration: 0.3, animated: true, completed: nil)
  }
  
  func rightTabBarButtonTapped() {
    let hidden = self.sideControl?.isSideViewItemHiddenAtIndex(1) ?? true
    self.sideControl?.sideViewItemAtIndex(1, hidden: !hidden, withDuration: 0.3, animated: true, completed: nil)
  }
  
  func maskViewDidTapped() {
    self.sideControl?.hideAllSideViewItemWithDuration(0.3, animated: true, completed: nil)
  }
}

