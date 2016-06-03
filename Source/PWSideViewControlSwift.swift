//
//  PWSideViewControlSwift.swift
//  PWSideViewControlSwift
//
//  Created by PeterWang on 7/16/15.
//  Copyright (c) 2015 PeterWang. All rights reserved.
//

import UIKit

//
// MARK: - Public Enum
//
public enum PWSideViewCoverMode {
  case FullInSuperView
  case CoverNavigationBarView
}

public enum PWSideViewSizeMode {
  case Scale
  case Constant
}

public enum PWSideViewHorizontalDirection: Int {
  case Center
  case Left
  case Right
}

public enum PWSideViewVerticalDirection: Int {
  case Center
  case Top
  case Bottom
}

//
// MARK: - PWSideViewDirection
//

public struct PWSideViewDirection {
  var horizontal: PWSideViewHorizontalDirection = .Left
  var vertical: PWSideViewVerticalDirection = .Center
  
  public init() {}
  public init(horizontal: PWSideViewHorizontalDirection, vertical: PWSideViewVerticalDirection) {
    self.horizontal = horizontal
    self.vertical = vertical
  }
}

//
// MARK: - PWSideViewSize
//

public struct PWSideViewSize {
  var widthValue: CGFloat = 1
  var widthSizeMode: PWSideViewSizeMode = .Scale
  var heightValue: CGFloat = 1
  var heightSizeMode: PWSideViewSizeMode = .Scale
  
  public init() {}
  public init(widthValue: CGFloat, widthSizeMode: PWSideViewSizeMode, heightValue: CGFloat, heightSizeMode: PWSideViewSizeMode) {
    self.widthValue = widthValue
    self.widthSizeMode = widthSizeMode
    self.heightValue = heightValue
    self.heightSizeMode = heightSizeMode
  }
}

//
// MARK: - PWSideViewAnimationItem
//

public struct PWSideViewAnimationItem {
  var path: UIBezierPath
  var duration: CFTimeInterval
}

//
// MARK: - PWSideViewItem
//

public class PWSideViewItem: Equatable {
  private(set) var view: UIView!
  var hiddenPosition = PWSideViewDirection()
  var shownPosition = PWSideViewDirection()
  var size = PWSideViewSize()
  
  private var constraints = [NSLayoutConstraint]()
  private var canShowHideSideView: Bool = true
  private var hidden: Bool = true
  
  public init(embedView: UIView, hiddenPosition: PWSideViewDirection = PWSideViewDirection(), shownPosition: PWSideViewDirection = PWSideViewDirection(), size: PWSideViewSize = PWSideViewSize()) {
    self.view = embedView
    
    if hiddenPosition.horizontal == .Center && hiddenPosition.vertical == .Center {
      NSException(name: "Hidden position error", reason: "PWSideViewItem not support 'center' hidden, please set one of horizontal or vertical to be NOT 'center'.", userInfo: nil).raise()
    }
    
    if shownPosition.horizontal == .Center && shownPosition.vertical == .Center {
      NSException(name: "Shown position error", reason: "PWSideViewItem not support 'center' shown, please set one of horizontal or vertical to be NOT 'center'.", userInfo: nil).raise()
    }
    
    self.hiddenPosition = hiddenPosition
    self.shownPosition = shownPosition
    self.size = size
  }
}

public func ==(lhs: PWSideViewItem, rhs: PWSideViewItem) -> Bool {
  return lhs.view == rhs.view
}

//
// MARK: - PWSideViewControlSwift
//
public class PWSideViewControlSwift: UIView, UIGestureRecognizerDelegate {
  // MARK: - Public Variables
  var coverMode: PWSideViewCoverMode = .FullInSuperView {
    didSet {
      addToView()
    }
  }
  var maskColor: UIColor = UIColor(white: 0, alpha: 0.5) {
    didSet {
      configView()
    }
  }
  var maskViewDidTapped: (() -> Void)?
  
  // MARK: - Private Variables
  private var embeddedView: UIView!
  private var sideViewItems = [PWSideViewItem]()
  
  // MARK: - Initializer
  public init(embeddedView: UIView) {
    super.init(frame: embeddedView.frame)
    self.embeddedView = embeddedView
    
    setupView()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.embeddedView = defaultEmbeddedView()
    
    setupView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.embeddedView = defaultEmbeddedView()
    
    setupView()
  }
  
  private func defaultEmbeddedView() -> UIView {
    if let currendtWindow = UIApplication.sharedApplication().keyWindow {
      return currendtWindow
    } else {
      let defaultEmbeddedView = UIView(frame: UIScreen.mainScreen().bounds)
      return defaultEmbeddedView
    }
  }
  
  // MARK: - Public functioins
  public func addSideViewItem(item: PWSideViewItem) -> Int {
    let index = self.sideViewItems.count
    self.sideViewItems.append(item)
    addSubview(item.view)
    setupSideViewLayoutConstraintsByItem(item, hidden: true)
    return index
  }
  
  public func isSideViewItemHiddenAtIndex(itemIndex: Int) -> Bool {
    if 0..<self.sideViewItems.count ~= itemIndex {
      return self.sideViewItems[itemIndex].hidden
    }
    return true
  }
  
  public func sideViewItemAtIndex(itemIndex: Int, hidden: Bool, withDuration duration: NSTimeInterval, animated: Bool, completed: (() -> Void)?) {
    guard 0..<self.sideViewItems.count ~= itemIndex else {
      return
    }
    
    let item = self.sideViewItems[itemIndex]
    guard item.canShowHideSideView else {
      return
    }
    
    item.canShowHideSideView = false
    item.hidden = hidden
    removeConstraints(item.constraints)
    item.view.removeConstraints(item.constraints)
    setupSideViewLayoutConstraintsByItem(item, hidden: hidden)
    
    if animated {
      if !hidden {
        self.hidden = false
      }

      UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { _ in
        self.alpha = hidden ? 0 : 1
        self.layoutIfNeeded()
        }, completion: { _ in
          item.canShowHideSideView = true
          self.hidden = hidden
          completed?()
      })
    } else {
      self.alpha = hidden ? 0 : 1
      item.canShowHideSideView = true
      self.hidden = hidden
      layoutIfNeeded()
      completed?()
    }
  }
  
  public func hideAllSideViewItemWithDuration(duration: NSTimeInterval, animated: Bool, completed: (() -> Void)?) {
    var needHideSideViewItems = [PWSideViewItem]()
    for item in self.sideViewItems {
      if !item.hidden {
        needHideSideViewItems.append(item)
      }
    }
    
    for item in needHideSideViewItems {
      item.canShowHideSideView = false
      item.hidden = true
      removeConstraints(item.constraints)
      item.view.removeConstraints(item.constraints)
      setupSideViewLayoutConstraintsByItem(item, hidden: true)
    }
    
    if animated {
      UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { _ in
        self.alpha = 0
        self.layoutIfNeeded()
        }, completion: { _ in
          for item in needHideSideViewItems {
            item.canShowHideSideView = true
          }
          self.hidden = true
          completed?()
      })
    } else {
      self.alpha = 0
      for item in needHideSideViewItems {
        item.canShowHideSideView = true
      }
      self.hidden = true
      layoutIfNeeded()
      completed?()
    }
  }
  
  // MARK: - Private functions
  private func setupView() {
        self.hidden = true
        self.alpha = 0
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(PWSideViewControlSwift.maskViewTapped(_:)))
    tapGR.delegate = self
    addGestureRecognizer(tapGR)
    configView()
    
    // Add view to
    addToView()
  }
  
  private func addToView() {
    switch self.coverMode {
    case .CoverNavigationBarView:
      if let currendtWindow = UIApplication.sharedApplication().delegate?.window ?? nil {
        currendtWindow.addSubview(self)
        setupViewLayoutConstraints()
      }
      
    default:
      self.embeddedView.addSubview(self)
      setupViewLayoutConstraints()
    }
  }
  
  private func setupViewLayoutConstraints() {
    if let superView = self.superview {
      self.translatesAutoresizingMaskIntoConstraints = false
      let topConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1, constant: 0)
      superView.addConstraint(topConstraint)
      
      let bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1, constant: 0)
      superView.addConstraint(bottomConstraint)
      
      let leadingConstraint = NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1, constant: 0)
      superView.addConstraint(leadingConstraint)
      
      let trailingConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1, constant: 0)
      superView.addConstraint(trailingConstraint)
    }
  }
  
  private func setupSideViewLayoutConstraintsByItem(sideViewItem: PWSideViewItem, hidden: Bool) {
    sideViewItem.view.translatesAutoresizingMaskIntoConstraints = false
    
    let pos: PWSideViewDirection
    if hidden {
      pos = sideViewItem.hiddenPosition
    } else {
      pos = sideViewItem.shownPosition
    }
    
    // Horizontal.
    switch pos.horizontal {
    case .Center:
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
      
    case .Left:
      let attribute: NSLayoutAttribute = hidden ? .Trailing : .Leading
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
      
    case .Right:
      let attribute: NSLayoutAttribute = hidden ? .Leading : .Trailing
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
    }
    
    // Vertical.
    switch pos.vertical {
    case .Center:
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
      
    case .Top:
      let attribute: NSLayoutAttribute = hidden ? .Bottom : .Top
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
      
    case .Bottom:
      let attribute: NSLayoutAttribute = hidden ? .Top : .Bottom
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
    }
    
    // Width.
    switch sideViewItem.size.widthSizeMode {
    case .Scale:
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: sideViewItem.size.widthValue, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
      
    case .Constant:
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: sideViewItem.size.widthValue)
      sideViewItem.view.addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
    }
    
    switch sideViewItem.size.heightSizeMode {
    case .Scale:
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: sideViewItem.size.heightValue, constant: 0)
      addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
      
    case .Constant:
      let constraint = NSLayoutConstraint(item: sideViewItem.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: sideViewItem.size.heightValue)
      sideViewItem.view.addConstraint(constraint)
      sideViewItem.constraints.append(constraint)
    }
  }
  
  // MARK: - Configure
  private func configView() {
    self.backgroundColor = self.maskColor
    setNeedsDisplay()
  }
  
  // MARK: - Gesture Recognizer Action
  func maskViewTapped(recognizer: UITapGestureRecognizer) {
    if self.maskViewDidTapped != nil {
      self.maskViewDidTapped!()
    } else {
      
    }
  }
  
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    if let touchView = touch.view where (touchView.isDescendantOfView(self) && touchView != self) {
      return false
    }
    
    return true
  }
}
